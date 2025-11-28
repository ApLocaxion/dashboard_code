import 'package:dashboard/common/env.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/pages/map_view/grid_view.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:dashboard/pages/map_view/search/markerLayer.dart';
import 'package:dashboard/pages/map_view/zone_layer%20copy.dart';
import 'package:dashboard/pages/map_view/zone_layer.dart';
import 'package:dashboard/pages/scan/search/svgLayer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchMapView extends StatefulWidget {
  const SearchMapView({super.key});
  @override
  State<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends State<SearchMapView> {
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final mapController = Get.find<MapController>(tag: 'mapController');
  final binController = Get.find<BinController>(tag: 'binController');

  double _startZoom = 10.0;
  Offset _startFocal = Offset.zero;
  Offset _worldAtFocalStart = Offset.zero;

  double get _scalePxPerMeter =>
      mapController.cfg.value.pxPerMeter * mapController.zoom.value;

  // Screen -> World (meters)
  Offset _screenToWorld(Offset screen) {
    return (screen - mapController.panPx.value) / _scalePxPerMeter;
  }

  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );
  double get _originX => -mapController.cfg.value.marginMeters;
  double get _originY => -mapController.cfg.value.marginMeters;
  double get _worldHm =>
      mapController.cfg.value.mapHeight +
      2 * mapController.cfg.value.marginMeters;
  Offset _toWorld(double xPx, double yPx) {
    final xm =
        _originX +
        (xPx - mapController.panPx.value.dx) / mapController.zoom.value;
    final heightPx = _worldHm * mapController.zoom.value;
    final yImg = heightPx - (yPx - mapController.panPx.value.dy);
    final ym = _originY + yImg / mapController.zoom.value;
    return Offset(xm, ym);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          const step = 0.12;
          final zoomDelta = event.scrollDelta.dy < 0 ? (1 + step) : (1 - step);
          final newZoom = (mapController.zoom.value * zoomDelta).clamp(
            1.0,
            300.0,
          );
          final worldAtFocal = _screenToWorld(event.position);
          final newScale = mapController.cfg.value.pxPerMeter * newZoom;
          final newPan = event.position - worldAtFocal * newScale;
          mapController.zoom.value = newZoom;
          mapController.panPx.value = newPan;
        }
      },
      child: MouseRegion(
        onHover: (event) {
          //
          Offset p = _toWorld(event.localPosition.dx, event.localPosition.dy);
          mapController.x.value = p.dx.toPrecision(3);
          mapController.y.value = p.dy.toPrecision(3);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (details) {
            _startZoom = mapController.zoom.value;
            _startFocal = details.focalPoint;
            _worldAtFocalStart = _screenToWorld(_startFocal);
          },
          onScaleUpdate: (details) {
            final newZoom = (_startZoom * details.scale).clamp(1.0, 300.0);
            final newScalePxPerMeter =
                mapController.cfg.value.pxPerMeter * newZoom;
            final targetPan =
                details.focalPoint - _worldAtFocalStart * newScalePxPerMeter;
            mapController.panPx.value = targetPan;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(
                  () => !mapController.showGrid.value
                      ? const SizedBox.shrink()
                      : GridLayer(
                          cfg: mapController.cfg.value,
                          zoom: mapController.zoom.value,
                          panPx: mapController.panPx.value,
                          minorStepM: 1,
                          majorStepM: 10,
                          showLabels: true,
                        ),
                ),
              ),
              Obx(() {
                return Positioned(
                  right: 20,
                  bottom: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        "X: ${mapController.x.value}, Y: ${mapController.y.value}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Positioned.fill(
              //   child: Obx(
              //     () => !mapController.showMap.value
              //         ? const SizedBox.shrink()
              //         : ImageLayer(
              //             cfg: cfg,
              //             zoom: mapController.zoom.value,
              //             panPx: mapController.panPx.value,
              //           ),
              //   ),
              // ),
              Positioned.fill(
                child: Obx(() {
                  return SvgLayer(
                    cfg: mapController.cfg.value,
                    zoom: mapController.zoom.value,
                    panPx: mapController.panPx.value,
                  );
                }),
              ),
              Obx(
                () => !mapController.showZone.value
                    ? const SizedBox.shrink()
                    : ZoneLayer2(
                        cfg: mapController.cfg.value,
                        zoom: mapController.zoom.value,
                        panPx: mapController.panPx.value,
                      ),
              ),
              Positioned.fill(
                child: Obx(() {
                  if (!mapController.showBin.value) {
                    return SizedBox.shrink();
                  }
                  // Touch RxLists inside Obx to register dependencies
                  final bins = binController.allBin.toList();
                  final containers = containerController.containerList.toList();
                  return MarkerLayer(
                    cfg: mapController.cfg.value,
                    zoom: mapController.zoom.value,
                    bins: bins,
                    panPx: mapController.panPx.value,
                    containers: containers,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget toggelButton(BuildContext context) {
    return Positioned(
      top: 60,
      right: 10,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        shadowColor: Colors.black26,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timeline_rounded,
                color: containerController.showTrajector.value
                    ? Colors.blueAccent
                    : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 6),
              Obx(
                () => Switch(
                  value: containerController.showTrajector.value,
                  activeColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey.shade300,
                  onChanged: (value) async {
                    containerController.showTrajector.value = value;
                    if (value) {
                      // final date = await showDatePicker(
                      //   context: context,
                      //   initialDate: DateTime.now(),
                      //   firstDate: DateTime(2020, 1, 1),
                      //   lastDate: DateTime(2100, 1, 1),
                      // );
                      // final time = await showTimePicker(
                      //   context: context,
                      //   initialTime: TimeOfDay(
                      //     hour: DateTime.now().hour,
                      //     minute: DateTime.now().minute,
                      //   ),
                      // );
                    }
                    // clear if value = false;
                    // containerController.trajectory.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
