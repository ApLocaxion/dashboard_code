import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/pages/map_view/forklift_layer.dart';
import 'package:dashboard/pages/map_view/grid_view.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:dashboard/pages/map_view/zone_layer.dart';
import 'package:dashboard/pages/simulate/darw_simulate.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double zoom = 10;
Offset panPx = const Offset(-700, -1200);

class SimulateView extends StatefulWidget {
  const SimulateView({super.key});
  @override
  State<SimulateView> createState() => _SimulateViewState();
}

class _SimulateViewState extends State<SimulateView> {
  final cfg = const MapConfig(
    widthMeters: 150,
    heightMeters: 150,
    marginMeters: 20,
    pxPerMeter: 1,
  );
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final binController = Get.find<BinController>(tag: 'binController');

  double _startZoom = 10.0;
  Offset _startPanPx = Offset.zero;
  Offset _startFocal = Offset.zero;
  Offset _worldAtFocalStart = Offset.zero;

  double get _scalePxPerMeter => cfg.pxPerMeter * zoom;

  // Screen -> World (meters)
  Offset _screenToWorld(Offset screen) {
    return (screen - panPx) / _scalePxPerMeter;
  }

  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  ); // ----- world extents (meters) with margins -----
  double get _originX => -cfg.marginMeters;
  double get _originY => -cfg.marginMeters;
  double get _worldHm => cfg.heightMeters + 2 * cfg.marginMeters;
  Offset _toWorld(double xPx, double yPx) {
    final xm = _originX + (xPx - panPx.dx) / zoom;
    final heightPx = _worldHm * zoom;
    final yImg = heightPx - (yPx - panPx.dy);
    final ym = _originY + yImg / zoom;
    return Offset(xm, ym);
  }

  final TextEditingController simulateDeviceId = TextEditingController();

  void _toggleKeyboard() {
    setState(() => _showVirtualKeyboard = !_showVirtualKeyboard);
    if (_showVirtualKeyboard) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  bool _showVirtualKeyboard = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    containerController.showTrajector.value = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          const step = 0.12;
          final zoomDelta = event.scrollDelta.dy < 0 ? (1 + step) : (1 - step);
          final newZoom = (zoom * zoomDelta).clamp(5.0, 500.0);
          final worldAtFocal = _screenToWorld(event.position);
          final newScale = cfg.pxPerMeter * newZoom;
          final newPan = event.position - worldAtFocal * newScale;
          setState(() {
            zoom = newZoom;
            panPx = newPan;
          });
        }
      },

      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onScaleStart: (details) {
                _startZoom = zoom;
                _startPanPx = panPx;
                _startFocal = details.focalPoint;
                _worldAtFocalStart = _screenToWorld(_startFocal);
              },
              onTapDown: (details) {
                if (homePageController.recordPoints.value) {
                  final s1 = _toWorld(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  );
                  homePageController.simulatePoints.add(s1);
                }
              },
              onScaleUpdate: (details) {
                final newZoom = (_startZoom * details.scale).clamp(5.0, 500.0);
                final newScalePxPerMeter = cfg.pxPerMeter * newZoom;
                final targetPan =
                    details.focalPoint -
                    _worldAtFocalStart * newScalePxPerMeter;
                setState(() {
                  panPx = targetPan;
                });
              },
              child: GridLayer(
                cfg: cfg,
                zoom: zoom,
                panPx: panPx,
                minorStepM: 1,
                majorStepM: 10,
                showLabels: true,
              ),
            ),
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
                panPx: panPx,
                containers: containers,
              );
            }),
          ),
          ZoneLayer(cfg: cfg, zoom: zoom, panPx: panPx),
          SimulationLayer(cfg: cfg, zoom: zoom, panPx: panPx),
          // searchButton(context),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: () {
                Get.toNamed('/scan');
              },
              icon: Icon(
                Icons.document_scanner_rounded,
                size: 30,
                color: const Color.fromARGB(255, 88, 85, 78),
              ),
            ),
          ),
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
                simulateDeviceId.clear();
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
        ],
      ),
    );
  }
}
