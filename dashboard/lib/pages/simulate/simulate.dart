import 'dart:math' as math;
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/common/env.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:dashboard/pages/map_view/forklift_layer.dart';
import 'package:dashboard/pages/map_view/grid_view.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:dashboard/pages/map_view/zone_layer.dart';
import 'package:dashboard/pages/scan/search/svgLayer.dart';
import 'package:dashboard/pages/simulate/darw_simulate.dart';
import 'package:dashboard/pages/simulate/zone_draft_overlay.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:dashboard/service/map_service.dart';
import 'package:dashboard/service/zone_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double zoom = 10;
// Offset panPx = const Offset(-700, -1200);

class SimulateView extends StatefulWidget {
  const SimulateView({super.key});
  @override
  State<SimulateView> createState() => _SimulateViewState();
}

class _SimulateViewState extends State<SimulateView> {
  final mapController = Get.find<MapController>(tag: 'mapController');
  MapConfig get cfg => mapController.cfg.value;

  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');

  final binController = Get.find<BinController>(tag: 'binController');

  double _startZoom = 10.0;
  Offset _startPanPx = Offset.zero;
  Offset _startFocal = Offset.zero;
  Offset _worldAtFocalStart = Offset.zero;

  double get _scalePxPerMeter => cfg.pxPerMeter * zoom;

  // Screen -> World (meters)
  Offset _screenToWorld(Offset screen) {
    return (screen - mapController.panPx.value) / _scalePxPerMeter;
  }

  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  ); // ----- world extents (meters) with margins -----
  double get _originX => -cfg.marginMeters;
  double get _originY => -cfg.marginMeters;
  double get _worldHm => cfg.mapHeight + 2 * cfg.marginMeters;
  Offset _toWorld(double xPx, double yPx) {
    final xm = _originX + (xPx - mapController.panPx.value.dx) / zoom;
    final heightPx = _worldHm * zoom;
    final yImg = heightPx - (yPx - mapController.panPx.value.dy);
    final ym = _originY + yImg / zoom;
    return Offset(xm, ym);
  }

  final TextEditingController simulateDeviceId = TextEditingController();
  final TextEditingController _zoneCodeController = TextEditingController();
  final TextEditingController _pxPerMeterController = TextEditingController();
  bool _isDrawingZone = false;
  bool _isSavingZone = false;
  Offset? _firstZoneCorner;
  List<Offset> _zoneDraft = [];
  bool _isUpdatingPx = false;
  late Worker _mapCfgWorker;

  void _toggleKeyboard() {
    setState(() => _showVirtualKeyboard = !_showVirtualKeyboard);
    if (_showVirtualKeyboard) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _startZoneDrawing() {
    setState(() {
      _isDrawingZone = true;
      _firstZoneCorner = null;
      _zoneDraft = [];
    });
    homePageController.recordPoints.value = false;
  }

  void _handleZoneTap(Offset worldPoint) {
    setState(() {
      if (_firstZoneCorner == null) {
        _firstZoneCorner = worldPoint;
        _zoneDraft = [worldPoint];
      } else {
        _zoneDraft = _buildRectangle(_firstZoneCorner!, worldPoint);
        _isDrawingZone = false;
        _firstZoneCorner = null;
      }
    });
  }

  List<Offset> _buildRectangle(Offset first, Offset second) {
    final minX = math.min(first.dx, second.dx);
    final maxX = math.max(first.dx, second.dx);
    final minY = math.min(first.dy, second.dy);
    final maxY = math.max(first.dy, second.dy);

    return [
      Offset(minX, minY),
      Offset(minX, maxY),
      Offset(maxX, maxY),
      Offset(maxX, minY),
    ];
  }

  List<ZoneModel> _findParentZones(List<Offset> newBoundary, int newZoneId) {
    final parents = <ZoneModel>[];
    for (final zone in zoneController.allZone) {
      if (zone.zoneId == newZoneId) continue;
      final parentBoundary = _mapBoundaryToOffsets(zone.boundary);
      if (parentBoundary.length < 3) continue;
      final inside = newBoundary.every(
        (p) => _isPointInsidePolygon(p, parentBoundary),
      );
      if (inside) {
        parents.add(zone);
      }
    }
    return parents;
  }

  List<ZoneModel> _findChildZones(List<Offset> newBoundary, int newZoneId) {
    final children = <ZoneModel>[];
    for (final zone in zoneController.allZone) {
      if (zone.zoneId == newZoneId) continue;
      final boundaryOffsets = _mapBoundaryToOffsets(zone.boundary);
      if (boundaryOffsets.length < 3) continue;
      final isInside = boundaryOffsets.every(
        (p) => _isPointInsidePolygon(p, newBoundary),
      );
      if (isInside) {
        children.add(zone);
      }
    }
    return children;
  }

  List<Offset> _mapBoundaryToOffsets(List<dynamic> boundary) {
    return boundary.map<Offset>((p) {
      final xVal = p['x'] ?? p['X'] ?? 0;
      final yVal = p['y'] ?? p['Y'] ?? 0;
      final x = (xVal is num) ? xVal.toDouble() : double.tryParse("$xVal") ?? 0;
      final y = (yVal is num) ? yVal.toDouble() : double.tryParse("$yVal") ?? 0;
      return Offset(x, y);
    }).toList();
  }

  bool _isPointInsidePolygon(Offset point, List<Offset> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;

      final intersect =
          ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx < (xj - xi) * (point.dy - yi) / (yj - yi + 0.0000001) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  Future<void> _saveZone() async {
    if (_isSavingZone) return;
    if (_zoneDraft.length < 4) {
      CommonWidgets().errorSnackbar(
        'Error',
        'Draw a rectangle on the map first',
      );
      return;
    }
    if (_zoneCodeController.text.trim().isEmpty) {
      CommonWidgets().errorSnackbar('Error', 'Enter zone code');
      return;
    }

    setState(() => _isSavingZone = true);

    final newZoneId = await ZoneService().createZone(
      code: _zoneCodeController.text.trim(),
      boundary: _zoneDraft,
    );

    if (newZoneId != null) {
      // find parent zones (if the new rectangle lies fully inside existing zones)
      final parentZones = _findParentZones(_zoneDraft, newZoneId);
      for (final parent in parentZones) {
        await ZoneService().updateZoneChildren(
          zone: parent,
          childIds: [...parent.childIds, newZoneId],
        );
      }

      // find child zones (existing zones fully contained within the new one)
      final childZones = _findChildZones(_zoneDraft, newZoneId);
      ZoneModel? newZone;
      for (final z in zoneController.allZone) {
        if (z.zoneId == newZoneId) {
          newZone = z;
          break;
        }
      }
      if (newZone != null && childZones.isNotEmpty) {
        final childIds = [
          ...newZone.childIds,
          ...childZones.map((z) => z.zoneId),
        ];
        await ZoneService().updateZoneChildren(
          zone: newZone,
          childIds: childIds,
        );
      }

      setState(() {
        _zoneDraft = [];
        _zoneCodeController.clear();
        _isDrawingZone = false;
        _firstZoneCorner = null;
      });
    }

    setState(() => _isSavingZone = false);
  }

  Future<void> _updatePxPerMeter() async {
    if (_isUpdatingPx) return;
    final parsed = double.tryParse(_pxPerMeterController.text.trim());
    if (parsed == null || parsed <= 0) {
      CommonWidgets().errorSnackbar('Error', 'Enter a valid px/m value');
      return;
    }

    setState(() => _isUpdatingPx = true);
    final success = await MapService().updatePxPerMeter(parsed);
    if (!success) {
      setState(() => _isUpdatingPx = false);

      return;
    }
    setState(() => _isUpdatingPx = false);
    ZoneService().getAllZone();
  }

  bool _showVirtualKeyboard = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    containerController.showTrajector.value = false;
    _pxPerMeterController.text = mapController.cfg.value.pxPerMeter
        .toStringAsFixed(2);
    _mapCfgWorker = ever<MapConfig>(mapController.cfg, (config) {
      _pxPerMeterController.text = config.pxPerMeter.toStringAsFixed(2);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    simulateDeviceId.dispose();
    _zoneCodeController.dispose();
    _pxPerMeterController.dispose();
    _mapCfgWorker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = cfg; // register dependency on map config
      return Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            const step = 0.12;
            final zoomDelta = event.scrollDelta.dy < 0
                ? (1 + step)
                : (1 - step);
            final newZoom = (zoom * zoomDelta).clamp(2.0, 500.0);
            final worldAtFocal = _screenToWorld(event.position);
            final newScale = cfg.pxPerMeter * newZoom;
            final newPan = event.position - worldAtFocal * newScale;
            setState(() {
              zoom = newZoom;
              mapController.panPx.value = newPan;
            });
          }
        },

        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _startZoom = zoom;
                  _startPanPx = mapController.panPx.value;
                  _startFocal = details.focalPoint;
                  _worldAtFocalStart = _screenToWorld(_startFocal);
                },
                onTapDown: (details) {
                  final worldPoint = _toWorld(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  );
                  if (_isDrawingZone) {
                    _handleZoneTap(worldPoint);
                    return;
                  }

                  if (homePageController.recordPoints.value) {
                    homePageController.simulatePoints.add(worldPoint);
                  }
                },
                onScaleUpdate: (details) {
                  final newZoom = (_startZoom * details.scale).clamp(
                    2.0,
                    500.0,
                  );
                  final newScalePxPerMeter = cfg.pxPerMeter * newZoom;
                  final targetPan =
                      details.focalPoint -
                      _worldAtFocalStart * newScalePxPerMeter;
                  setState(() {
                    mapController.panPx.value = targetPan;
                  });
                },
                child: GridLayer(
                  cfg: cfg,
                  zoom: zoom,
                  panPx: mapController.panPx.value,
                  minorStepM: 1,
                  majorStepM: 10,
                  showLabels: true,
                ),
              ),
            ),
            Positioned.fill(
              child: Obx(() {
                final _ = mapController.zoom.value;
                final __ = mapController.cfg.value;
                return SvgLayer(
                  cfg: mapController.cfg.value,
                  zoom: zoom,
                  panPx: mapController.panPx.value,
                  // zoom: mapController.zoom.value,
                  // panPx: mapController.panPx.value,
                );
              }),
            ),
            Positioned.fill(
              child: Obx(() {
                // Touch RxLists inside Obx to register dependencies
                final bins = binController.allBin.toList();
                final containers = containerController.containerList.toList();
                return MarkerOverlay(
                  cfg: cfg,
                  zoom: zoom,
                  bins: bins,
                  panPx: mapController.panPx.value,
                  containers: containers,
                );
              }),
            ),
            Obx(() {
              final _ = zoneController.allZone;
              return ZoneLayer(
                cfg: cfg,
                zoom: zoom,
                panPx: mapController.panPx.value,
              );
            }),
            SimulationLayer(
              cfg: cfg,
              zoom: zoom,
              panPx: mapController.panPx.value,
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: ZoneDraftOverlay(
                  cfg: cfg,
                  zoom: zoom,
                  panPx: mapController.panPx.value,
                  zonePoints: _zoneDraft,
                ),
              ),
            ),
            // searchButton(context),
            // Positioned(
            //   top: 20,
            //   left: 20,
            //   child: IconButton(
            //     onPressed: () {
            //       Get.toNamed('/scan');
            //     },
            //     icon: Icon(
            //       Icons.document_scanner_rounded,
            //       size: 30,
            //       color: const Color.fromARGB(255, 88, 85, 78),
            //     ),
            //   ),
            // ),
            Positioned(
              top: 20,
              right: 20,
              child: Obx(
                () => ElevatedButton(
                  onPressed: () async {
                    //
                    homePageController.recordPoints.value =
                        !homePageController.recordPoints.value;
                  },
                  child: homePageController.recordPoints.value
                      ? Text("Stop points ")
                      : Text("Record points "),
                ),
              ),
            ),
            Positioned(
              top: 60,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  //
                  if (homePageController.simulatePoints.length < 2) {
                    CommonWidgets().errorSnackbar(
                      "Error",
                      'Add atleast 2 points',
                    );
                  } else {
                    await ContainerService().startSimulation();
                  }
                },
                child: Text("Start Simulation"),
              ),
            ),
            Positioned(
              top: 100,
              right: 20,
              child: IconButton(
                onPressed: () async {
                  //
                  setState(() {
                    simulateDeviceId.clear();
                    _zoneCodeController.clear();
                    _zoneDraft = [];
                    _firstZoneCorner = null;
                    _isDrawingZone = false;
                  });
                  homePageController.simulatePoints.value = [];
                  homePageController.recordPoints.value = false;
                },
                icon: Icon(Icons.refresh),
              ),
            ),
            Positioned(
              top: 20,
              right: MediaQuery.of(context).size.width / 4,
              child: Material(
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: TextFormField(
                        controller: simulateDeviceId,
                        focusNode: _focusNode,
                        onChanged: (value) {
                          homePageController.simulateDeviceId.value =
                              simulateDeviceId.text.trim();
                        },
                        decoration: InputDecoration(
                          labelText: 'Enter device id',
                          border: const OutlineInputBorder(),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 94, 204, 255),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: _showVirtualKeyboard
                                    ? 'Hide virtual keyboard'
                                    : 'Show virtual keyboard',
                                child: IconButton(
                                  icon: const Icon(Icons.keyboard),
                                  onPressed: _toggleKeyboard,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Map scale',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Current: ${cfg.pxPerMeter.toStringAsFixed(2)} px/m',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _pxPerMeterController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'px per meter',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 94, 204, 255),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _isUpdatingPx ? null : _updatePxPerMeter,
                            child: _isUpdatingPx
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Update scale'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create zone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 260,
                            child: TextField(
                              controller: _zoneCodeController,
                              decoration: InputDecoration(
                                labelText: 'Zone code',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 94, 204, 255),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isDrawingZone
                                ? 'Tap two opposite corners on the map'
                                : _zoneDraft.length >= 4
                                ? 'Rectangle ready to save'
                                : 'Tap "Draw zone" then pick two corners',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _startZoneDrawing,
                                child: Text(
                                  _isDrawingZone ? 'Tap corners' : 'Draw zone',
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _isSavingZone ? null : _saveZone,
                                child: _isSavingZone
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save zone'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
