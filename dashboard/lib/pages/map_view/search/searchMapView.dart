import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/pages/map_view/forklift_layer.dart';
import 'package:dashboard/pages/map_view/grid_view.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:dashboard/pages/map_view/search/markerLayer.dart';
import 'package:dashboard/pages/map_view/search/search.dart';
import 'package:dashboard/pages/map_view/zone_layer.dart';
import 'package:dashboard/pages/scan/search/image_layer.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:get/get.dart';

class SearchMapView extends StatefulWidget {
  const SearchMapView({super.key});
  @override
  State<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends State<SearchMapView> {
  final cfg = const MapConfig(
    widthMeters: 150,
    heightMeters: 150,
    marginMeters: 20,
    pxPerMeter: 1,
  );
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final mapController = Get.find<MapController>(tag: 'mapController');
  final binController = Get.find<BinController>(tag: 'binController');

  double _startZoom = 10.0;
  Offset _startFocal = Offset.zero;
  Offset _worldAtFocalStart = Offset.zero;

  double get _scalePxPerMeter => cfg.pxPerMeter * mapController.zoom.value;

  // Screen -> World (meters)
  Offset _screenToWorld(Offset screen) {
    return (screen - mapController.panPx.value) / _scalePxPerMeter;
  }

  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          const step = 0.12;
          final zoomDelta = event.scrollDelta.dy < 0 ? (1 + step) : (1 - step);
          final newZoom = (mapController.zoom.value * zoomDelta).clamp(
            5.0,
            500.0,
          );
          final worldAtFocal = _screenToWorld(event.position);
          final newScale = cfg.pxPerMeter * newZoom;
          final newPan = event.position - worldAtFocal * newScale;
          mapController.zoom.value = newZoom;
          mapController.panPx.value = newPan;
        }
      },
      child: GestureDetector(
        onScaleStart: (details) {
          _startZoom = mapController.zoom.value;
          _startFocal = details.focalPoint;
          _worldAtFocalStart = _screenToWorld(_startFocal);
        },
        onScaleUpdate: (details) {
          final newZoom = (_startZoom * details.scale).clamp(5.0, 500.0);
          final newScalePxPerMeter = cfg.pxPerMeter * newZoom;
          final targetPan =
              details.focalPoint - _worldAtFocalStart * newScalePxPerMeter;
          mapController.panPx.value = targetPan;
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                return GridLayer(
                  cfg: cfg,
                  zoom: mapController.zoom.value,
                  panPx: mapController.panPx.value,
                  minorStepM: 1,
                  majorStepM: 10,
                  showLabels: true,
                );
              }),
            ),
            Positioned.fill(
              child: Obx(() {
                return ImageLayer(
                  cfg: cfg,
                  zoom: mapController.zoom.value,
                  panPx: mapController.panPx.value,
                );
              }),
            ),
            Obx(() {
              return ZoneLayer(
                cfg: cfg,
                zoom: mapController.zoom.value,
                panPx: mapController.panPx.value,
              );
            }),
            Positioned.fill(
              child: Obx(() {
                // Touch RxLists inside Obx to register dependencies
                final bins = binController.allBin.toList();
                final containers = containerController.containerList.toList();
                return MarkerLayer(
                  cfg: cfg,
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
    );
  }

  Widget searchButton(BuildContext context) {
    return Positioned(
      top: 10,
      right: 10,
      child: ElevatedButton(
        onPressed: () {
          //
          showSearchPanel(context);
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
        ),
        child: const Icon(Icons.search, size: 30, color: Colors.amber),
      ),
    );
  }

  Widget spaghettiSlider(BuildContext context) {
    return Positioned(
      top: 120,
      right: 10,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 80, 42, 42),
        surfaceTintColor: Colors.amber,
        shadowColor: Colors.black26,
        child: Container(
          width: 320,
          height: 420,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blueGrey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.blueGrey.shade100, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Date Range",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1, height: 16),
              Expanded(
                child: RangeDatePicker(
                  centerLeadingDate: true,
                  minDate: DateTime(2020, 10, 10),
                  maxDate: DateTime.now(),
                  onStartDateChanged: (value) async {},
                  onEndDateChanged: (value) async {
                    // final time = await showTimePicker(
                    //   context: context,
                    //   initialTime: TimeOfDay(
                    //     hour: DateTime.now().hour,
                    //     minute: DateTime.now().minute,
                    //   ),
                    // );
                  },
                  onRangeSelected: (range) async {
                    // Handle selected range
                    ContainerService().getAllPosition(
                      deviceId: "fake-device-001",
                      startDate: range.start,
                      endDate: range.end,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text("Apply Range"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Apply selected range action
                  },
                ),
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
