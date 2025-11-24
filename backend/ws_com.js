// require("dotenv").config();
const WebSocket = require("ws");

const wsUri = process.env.WS_URI;

let db;
let zones = [];
const lastZoneByDevice = new Map();
global.isCarring = false;

// Lightweight publisher WS server for frontend subscribers
const publisher = {
  wss: null,
  start() {
    if (this.wss) return; // already started
    const port = Number(
      process.env.PUB_WS_PORT || process.env.WS_PUB_PORT || 8081
    );
    this.wss = new WebSocket.Server({ port });
    this.wss.on("connection", (ws) => {
      try {
        ws.send(JSON.stringify({ type: "ready", message: "connected" }));
      } catch (_) {}
    });
    console.log(`WS publisher listening on port ${port}`);
  },
  broadcast(payload) {
    if (!this.wss) return;
    const data = JSON.stringify(payload);
    for (const client of this.wss.clients) {
      if (client.readyState === WebSocket.OPEN) {
        try {
          client.send(data);
        } catch (_) {}
      }
    }
  },
};

function broadcast(payload) {
  publisher.broadcast(payload);
}

/* ---------------------- CONNECT TO MONGO ---------------------- */
async function connectDB(externalDB) {
  if (externalDB) {
    db = externalDB;
    console.log("✅ Using external MongoDB instance (from main.js)");
  } else {
    console.error("❌ No external MongoDB instance provided");
  }

  zones = await db.collection("zones").find({ active: true }).toArray();
  console.log(`Loaded ${zones.length} active zones`);

  const lastPositions = await db
    .collection("last_positions")
    .find({})
    .toArray();
  console.log(`Loaded ${lastPositions.length} documents from last_positions`);

  for (const doc of lastPositions) {
    if (doc && doc.pose) {
      const matchedZone = checkZones(doc.pose);
      if (matchedZone) {
        console.log(`✅ Pose inside zone ${matchedZone.code}`);
      } else {
        console.log(
          `❌ Pose outside all zones: (${doc.pose.x}, ${doc.pose.y})`
        );
      }
    }
  }
}

/* ---------------------- ZONE TRANSITION ---------------------- */
async function handleZoneTransition(deviceId, prevZone, newZone, pose) {
  if (prevZone?.code === newZone?.code) return;

  // Determine if this is an entry or exit event
  let event = null;
  let zoneCode = null;

  if (!prevZone && newZone) {
    event = "enter";
    zoneCode = newZone.code;
  } else if (prevZone && !newZone) {
    event = "exit";
    zoneCode = prevZone.code;
  } else if (prevZone && newZone) {
    // transitioned between zones: exit previous, enter new
    // optionally, record both events separately
    const exitEvent = {
      deviceId,
      event: "exit",
      zone: prevZone.code,
      timestamp: pose["timestamp"],
      pose,
    };
    const enterEvent = {
      deviceId,
      event: "enter",
      zone: newZone.code,
      timestamp: pose["timestamp"],
      pose,
    };
    await db.collection("zone_events").insertMany([exitEvent, enterEvent]);
    console.log(`🚨 Zone switched: ${prevZone.code} → ${newZone.code}`);
    var transition = enterEvent;
    publisher.broadcast({
      type: "zone",
      transition,
    });
    transition = exitEvent;
    publisher.broadcast({
      type: "zone",
      transition,
    });
    return;
  }

  if (!event) return; // nothing to record

  transition = {
    deviceId,
    event, // "enter" | "exit"
    zone: zoneCode,
    timestamp: pose["timestamp"],
    pose,
  };
  publisher.broadcast({
    type: "zone",
    transition,
  });

  await db.collection("zone_events").insertOne(transition);

  // if (global.isCarring) {
  //   await db
  //     .collection("bins")
  //     .updateOne({ binId: binId }, { $set: { zoneCode: zoneCode } });
  // }

  console.log(`🚨 Zone ${event}: ${zoneCode}`);
  console.log(`At: ${transition.timestamp}`);
  console.log("--------------------------------------");

  if (event === "enter" && newZone) onPositionInZone(pose, newZone);
}

/* ---------------------- GEOMETRY UTILITIES ---------------------- */
function parsePolygonWKT(wkt) {
  try {
    const coordsString = wkt.match(/\(\((.*?)\)\)/)[1];
    return coordsString.split(",").map((pair) => {
      const [x, y] = pair.trim().split(" ").map(Number);
      return [x, y];
    });
  } catch {
    console.error("⚠️ Invalid WKT boundary:", wkt);
    return [];
  }
}

function pointInPolygon(point, polygon) {
  const [x, y] = point;
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const [xi, yi] = polygon[i];
    const [xj, yj] = polygon[j];
    const intersect =
      yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi;
    if (intersect) {
      inside = !inside;
    }
  }
  return inside;
}

function checkZones(pose) {
  const point = [pose.x, pose.y];

  // First pass — find all zones that contain the point
  let matchedZones = [];

  for (const zone of zones) {
    const polygonCoords = parsePolygonWKT(zone.boundary);
    if (!polygonCoords.length) continue;

    if (pointInPolygon(point, polygonCoords)) {
      if (pose.z >= zone.zmin && pose.z <= zone.zmax) {
        matchedZones.push(zone);
      }
    }
  }

  if (matchedZones.length === 0) return null;

  // If EXACTLY ONE matched and it has no hierarchy → return directly
  if (matchedZones.length === 1) {
    const z = matchedZones[0];

    // Check child zones first (child overrides parent)
    if (z.hasChild && Array.isArray(z.chlidId)) {
      for (const childId of z.chlidId) {
        const childZone = zones.find((zz) => zz.zoneId === childId);
        if (childZone && isPoseInsideZone(pose, childZone)) {
          return childZone;
        }
      }
    }

    // If zone has parent → return parent instead
    if (z.hasParent && Array.isArray(z.parentId)) {
      const parentZone = zones.find((zz) => zz.zoneId === z.parentId[0]);
      return parentZone || z;
    }

    return z;
  }

  // If MULTIPLE zones match → always return the smallest or deepest zone (child)
  const childZones = matchedZones.filter((z) => z.hasParent);
  if (childZones.length > 0) return childZones[0];

  // If no child zones → return the first matched
  return matchedZones[0];
}

// Helper to check if pose inside zone (reuse your logic)
function isPoseInsideZone(pose, zone) {
  const point = [pose.x, pose.y];
  const polygonCoords = parsePolygonWKT(zone.boundary);
  if (!polygonCoords.length) return false;

  return (
    pointInPolygon(point, polygonCoords) &&
    pose.z >= zone.zmin &&
    pose.z <= zone.zmax
  );
}

const INTERVAL_MS = 100; // send pose every 100 ms
const STEPS_PER_SEGMENT = 50; // how many steps to go from one point to the next

async function simulate(points, deviceId) {
  if (!points || points.length < 2) {
    console.warn("simulate: need at least 2 points");
    return Promise.reject(new Error("simulate: need at least 2 points"));
  }

  let segmentIndex = 0;
  let step = 0;

  return new Promise((resolve, reject) => {
    const timer = setInterval(() => {
      try {
        if (segmentIndex >= points.length - 1) {
          clearInterval(timer);
          console.log("Simulation finished");
          resolve(); // <-- tell the caller we're done
          return;
        }

        const start = points[segmentIndex];
        const end = points[segmentIndex + 1];

        const t = step / STEPS_PER_SEGMENT; // 0..1
        const x = lerp(start.x, end.x, t);
        const y = lerp(start.y, end.y, t);

        const measuredX = x;
        const measuredY = y;

        async function publishPose(measuredX, measuredY, deviceId) {
          const pose = {
            x: measuredX,
            y: measuredY,
            z: 1.1,
            timestamp: new Date().toISOString(),
          };

          publisher.broadcast({
            type: "simulate",
            deviceId,
            pose,
          });

          console.log(
            `[${pose.timestamp}] X=${measuredX.toFixed(
              3
            )}, Y=${measuredY.toFixed(3)}`
          );
          const matchedZone = checkZones(pose);
          const prevZone = lastZoneByDevice.get(deviceId) || null;
          await handleZoneTransition(deviceId, prevZone, matchedZone, pose);
          lastZoneByDevice.set(deviceId, matchedZone);
          try {
            await db.collection("last_positions").updateOne(
              { slamCoreId: deviceId },
              {
                $set: {
                  pose: pose,
                  zoneCode: matchedZone ? matchedZone.code : null,
                  updatedAt: new Date(),
                },
              },
              { upsert: true }
            );
          } catch (e) {
            console.log(e);
          }
        }
        publishPose(measuredX, measuredY, deviceId);
        step++;

        if (step > STEPS_PER_SEGMENT) {
          step = 0;
          segmentIndex++;
        }
      } catch (err) {
        clearInterval(timer);
        reject(err); // <-- bubble errors up to the route
      }
    }, INTERVAL_MS);
  });
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}
/* ---------------------- LOGGING WHEN IN ZONE ---------------------- */
function onPositionInZone(pose, zone) {
  console.log("🚩 POSITION INSIDE ZONE DETECTED");
  console.log("Zone Code:", zone.code);
  console.log("Zone Title:", zone.title);
  console.log("Zone Description:", zone.description);
  console.log("Position:", {
    x: pose.x,
    y: pose.y,
    z: pose.z,
    timestamp: pose.timestamp,
  });
  console.log("--------------------------------------");
}

/* ---------------------- WEBSOCKET HANDLER ---------------------- */
function startSocket() {
  const uri = process.env.WS_URI || wsUri;
  if (!uri) {
    console.error("WS_URI not set; skipping device socket");
    return;
  }

  let socket;
  try {
    socket = new WebSocket(uri);
  } catch (err) {
    console.error("Failed to create WebSocket:", err.message || err);
    return;
  }

  socket.onopen = () => {
    console.log("✅ Connected to raw WebSocket");
    socket.send(JSON.stringify({ start: ["Pose"] }));
  };

  socket.onmessage = async (event) => {
    const data = JSON.parse(event.data);
    console.log("Received pose data", data);

    try {
      if (data.pose) {
        const deviceId = data.slamCoreId || "FORKLIFT-001";
        const pose = data.pose;
        // validatePose(pose);

        await db
          .collection("all_positions")
          .insertOne({ deviceId, pose: pose });
        console.log("Saved to all_positions collection");

        // console.log(result);
        console.log("Updated last_positions collection");

        const matchedZone = checkZones(pose);
        const prevZone = lastZoneByDevice.get(deviceId) || null;
        await handleZoneTransition(deviceId, prevZone, matchedZone, pose);
        lastZoneByDevice.set(deviceId, matchedZone);

        result = await db.collection("last_positions").updateOne(
          { slamCoreId: deviceId },
          {
            $set: {
              pose: pose,
              zoneCode: matchedZone ? matchedZone.code : null,
              updatedAt: new Date(),
            },
          },
          { upsert: true }
        );

        // Publish normalized pose to subscribers
        publisher.broadcast({
          type: "pose",
          deviceId,
          pose: pose,
          zone: matchedZone ? matchedZone.code : "outside",
        });
      }
    } catch (error) {
      console.error("Error saving to MongoDB:", error);
    }
  };

  socket.onerror = (error) => console.error("WebSocket error:", error);
  socket.onclose = (e) => console.log("Disconnected from device:", e.reason);
}

/* ---------------------- EXPORT ENTRY ---------------------- */
async function init(externalDB) {
  await connectDB(externalDB);
  // Start WS publisher for frontend clients
  publisher.start();
  // startSocket();
  console.log("System ready to receive pose data from device");
}

module.exports = { init, checkZones, simulate, broadcast };
