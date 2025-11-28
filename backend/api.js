const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");
const { checkZones, simulate, broadcast, refreshZones } = require("./ws_com");

const app = express();
app.use(cors());
app.use(express.json());

let db;
const MAP_CONFIG_FILE = path.join(__dirname, "map_config.json");

function loadMapConfig() {
  try {
    if (fs.existsSync(MAP_CONFIG_FILE)) {
      const raw = fs.readFileSync(MAP_CONFIG_FILE, "utf8");
      const parsed = JSON.parse(raw);
      return {
        pxPerMeter: Number(parsed.pxPerMeter) || 5.7,
        mapWidth: Number(parsed.mapWidth) || 279,
        mapHeight: Number(parsed.mapHeight) || 288,
        marginMeters: Number(parsed.marginMeters) || 20,
      };
    }
  } catch (err) {
    console.warn("Could not read map_config.json, using defaults:", err.message);
  }
  return {
    pxPerMeter: 5.7,
    mapWidth: 279,
    mapHeight: 288,
    marginMeters: 20,
  };
}

function persistMapConfig(cfg) {
  try {
    fs.writeFileSync(MAP_CONFIG_FILE, JSON.stringify(cfg, null, 2));
  } catch (err) {
    console.warn("Could not persist map_config.json:", err.message);
  }
}

let mapConfig = loadMapConfig();

/* ---------------------- INDEX INITIALIZATION ---------------------- */
async function ensureIndexes(db) {
  await db.collection("bins").createIndex({ binId: 1 }, { unique: true });
  await db
    .collection("last_positions")
    .createIndex({ slamCoreId: 1 }, { unique: true });
  await db
    .collection("all_positions")
    .createIndex({ deviceId: 1, "pose.timestamp": -1 });
  await db.collection("zones").createIndex({ code: 1 }, { unique: true });
  console.log("✅ Indexes ensured");
}

/* ---------------------- ROUTES ---------------------- */

/**
 * 1️⃣ Get last position data by slamCoreId
 * GET /api/last-position/
 */
app.get("/api/last_position", async (req, res) => {
  try {
    const data = await db.collection("last_positions").find().toArray();
    if (!data) return res.status(404).json({ message: "No data found" });
    res.json(data);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET /api/zone_events/
 */
app.get("/api/zone_events", async (req, res) => {
  try {
    const data = await db.collection("zone_events").find().toArray();
    if (!data) return res.status(404).json({ message: "No data found" });
    res.json(data);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 2️⃣ Get all position history
 * GET /api/all-positions
 * Optional query params: slamCoreId, limit
 */
app.get("/api/all_positions", async (req, res) => {
  try {
    const { deviceId, startDate, endDate } = req.query;

    if (!deviceId || !startDate || !endDate) {
      return res.status(400).json({
        error: "Missing required parameters: deviceId, startDate, or endDate",
      });
    }

    // Parse timestamp range
    const start = new Date(startDate);
    const end = new Date(endDate);

    // Build filter for MongoDB
    const filter = {
      deviceId,
      "pose.timestamp": {
        $gte: start.toISOString(),
        $lte: end.toISOString(),
      },
    };

    // Query MongoDB
    const data = await db
      .collection("all_positions")
      .find(filter, {
        projection: {
          _id: 0,
          x: "$pose.x",
          y: "$pose.y",
          z: "$pose.z",
          timestamp: "$pose.timestamp",
        },
      })
      .sort({ "pose.timestamp": 1 })
      .toArray();

    // Map results to simplified list
    const positions = data.map((d) => ({
      x: d.x,
      y: d.y,
      z: d.z,
      timestamp: d.timestamp,
    }));

    res.json(positions);
  } catch (err) {
    console.error("❌ Error fetching positions:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 3️⃣ All bin positions
 * GET /api/simulate → start simulating slamCore data for given points
 */
app.post("/api/simulate", async (req, res) => {
  const { points, deviceId = "FORKLIFT-001" } = req.body;

  if (!points || points.length < 2) {
    return res.status(400).json({ error: "no points" });
  }

  try {
    await simulate(points, deviceId); // pass deviceID if needed
    res.status(200).json({ message: "success", deviceId });
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 3️⃣ All bin positions
 * GET /api/bins → get all
 * POST /api/bins → create/update
 */
app.get("/api/bins", async (req, res) => {
  try {
    const { binId } = req.query;

    const filter = {};
    if (binId) {
      filter.binId = binId; // or _id if using ObjectId
    }

    const bins = await db.collection("bins").find(filter).toArray();
    res.json(bins);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * GET map config (pxPerMeter, dimensions)
 */
app.get("/api/map_config", async (_req, res) => {
  try {
    res.json(mapConfig);
  } catch (err) {
    console.error("Error reading map config:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * POST map config (supports pxPerMeter, mapWidth, mapHeight, marginMeters)
 */
app.post("/api/map_config", async (req, res) => {
  try {
    const { pxPerMeter, mapWidth, mapHeight, marginMeters } = req.body || {};
    if (
      pxPerMeter === undefined &&
      mapWidth === undefined &&
      mapHeight === undefined &&
      marginMeters === undefined
    ) {
      return res.status(400).json({ error: "No fields to update" });
    }

    const updated = { ...mapConfig };
    const setNumber = (key, value) => {
      const n = Number(value);
      if (Number.isFinite(n) && n > 0) {
        updated[key] = n;
      }
    };

    setNumber("pxPerMeter", pxPerMeter);
    setNumber("mapWidth", mapWidth);
    setNumber("mapHeight", mapHeight);
    setNumber("marginMeters", marginMeters);

    mapConfig = updated;
    persistMapConfig(mapConfig);

    res.status(200).json(mapConfig);
  } catch (err) {
    console.error("Error updating map config:", err);
    res.status(500).json({ error: err.message });
  }
});

app.get("/api/zones", async (req, res) => {
  try {
    const zones = await db.collection("zones").find({}).toArray();
    const formatted = zones.map((z) => {
      let boundaryList = [];

      if (z.boundary && typeof z.boundary === "string") {
        // Example: "POLYGON ((9 1, 9 2, 10 2, 10 1, 9 1))"
        const match = z.boundary.match(/\(\(([^)]+)\)\)/);
        if (match) {
          boundaryList = match[1]
            .trim()
            .split(",")
            .map((pair) => {
              const [x, y] = pair.trim().split(/\s+/).map(Number);
              return { x, y };
            });
        }
      }

      return {
        ...z,
        boundary: boundaryList, // replace WKT with structured list
      };
    });
    res.json(formatted);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * POST /api/zones - create or update a zone
 */
app.post("/api/zones", async (req, res) => {
  try {
    const {
      zoneId,
      code,
      hasChild = false,
      chlidId = [],
      active = true,
      title = "",
      description = "",
      boundary,
      zmax = 100,
      zmin = -1,
    } = req.body || {};

    if (!code || !boundary) {
      return res.status(400).json({ error: "code and boundary are required" });
    }

    const sanitized = {
      zoneId: Number.isFinite(Number(zoneId)) ? Number(zoneId) : Date.now(),
      code: String(code).trim(),
      hasChild: Boolean(hasChild),
      chlidId: Array.isArray(chlidId) ? chlidId : [],
      active: Boolean(active),
      title: title || String(code).trim(),
      description: description || "",
      boundary: String(boundary),
      zmax: Number(zmax),
      zmin: Number(zmin),
    };

    await db.collection("zones").updateOne(
      { code: sanitized.code },
      { $set: sanitized },
      { upsert: true }
    );

    await refreshZones();

    res.status(201).json({ message: "zone saved", zone: sanitized });
  } catch (err) {
    console.error("�?O Error:", err);
    res.status(500).json({ error: err.message });
  }
});

// POST or PUT for adding/updating bin position, load/unload info
app.post("/api/bins", async (req, res) => {
  try {
    console.log(req);
    const { binId, status, forkliftId } = req.body;
    const weightLbsRaw = req.body.weightLbs;
    const capacityLbsRaw = req.body.capacityLbs;
    const dwellTime = req.body.dwellTime ?? null;

    if (!binId) return res.status(400).json({ error: "binId is required" });
    const normStatus = String(status || "").toLowerCase();
    if (!["load", "unload"].includes(normStatus)) {
      return res
        .status(400)
        .json({ error: "status must be 'load' or 'unload'" });
    }
    if (normStatus == "load") {
      global.isCarring = true;
    } else {
      global.isCarring = false;
    }
    const rows = await db.collection("last_positions").find().toArray();
    console.log("All rows:", rows);
    // Optional pose lookup
    const lastPose = forkliftId
      ? await db
          .collection("last_positions")
          .findOne({ slamCoreId: forkliftId })
      : null;

    const pose = lastPose?.pose || null;
    const position = pose
      ? {
          x: Number(pose.x),
          y: Number(pose.y),
          z: Number(pose.z),
          timestamp: pose.timestamp ? new Date(pose.timestamp) : new Date(),
        }
      : null;

    const matchedZone = position ? checkZones(position) : null;

    const weightLbs = Number(weightLbsRaw);
    const capacityLbs = Number(capacityLbsRaw);

    const set = {
      forkliftId: forkliftId ?? null,
      status: normStatus,
      position,
      zoneCode: matchedZone?.code ?? null,
      weightLbs: Number.isFinite(weightLbs) ? weightLbs : null,
      capacityLbs: Number.isFinite(capacityLbs) ? capacityLbs : null,
      dwellTime,
    };

    const result = await db.collection("bins").findOneAndUpdate(
      { binId },
      {
        $set: set,
        $setOnInsert: { binId, createdAt: new Date() },
        $currentDate: { updatedAt: true },
      },
      { upsert: true, returnDocument: "after" }
    );

    broadcast({
      type: "bin",
    });

    res.status(200).json({ message: "bin updated" });
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * 5️⃣ SMART SEARCH
 * GET /api/search?binId=BIN123
 * GET /api/search?zone=ZONE_CODE
 */
app.get("/api/search", async (req, res) => {
  try {
    const { binId, zone } = req.query;

    if (!binId && !zone)
      return res.status(400).json({ error: "Specify binId or zone" });

    let result = {};

    if (binId) {
      const bin = await db.collection("bins").findOne({ binId });
      if (!bin) return res.status(404).json({ error: "Bin not found" });

      const zoneEvents = bin.carriedBy
        ? await db
            .collection("zone_events")
            .find({ deviceId: bin.carriedBy })
            .sort({ timestamp: -1 })
            .limit(10)
            .toArray()
        : await db
            .collection("bin_events")
            .find({ binId })
            .sort({ timestamp: -1 })
            .limit(10)
            .toArray();

      const lastEvent = zoneEvents[0];
      result = {
        binId,
        currentZone: bin.zoneCode,
        lastPosition: bin.position,
        lastZoneEntry: lastEvent ? lastEvent.timestamp : null,
        zoneHistory: zoneEvents,
      };
    }

    if (zone) {
      const binsInZone = await db
        .collection("bins")
        .find({ zoneCode: zone })
        .toArray();
      result = { zone, bins: binsInZone };
    }

    res.json(result);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).json({ error: err.message });
  }
});

/* ---------------------- EXPORT FUNCTION ---------------------- */
async function startApiServer(database) {
  db = database;

  await ensureIndexes(db);

  const PORT = process.env.PORT || 4000;
  app.listen(PORT, () => console.log(`🚀 API running on port ${PORT}`));
}

module.exports = { startApiServer };
