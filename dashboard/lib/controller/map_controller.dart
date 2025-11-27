import 'dart:ui';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:get/get_rx/get_rx.dart';

class MapController {
  var panPx = Offset(-700, -1200).obs;
  RxDouble zoom = 10.0.obs;

  RxBool showZone = true.obs;
  RxBool showMap = true.obs;
  RxBool showBin = true.obs;
  RxBool showGrid = true.obs;

  RxDouble x = 0.1.obs;
  RxDouble y = 0.1.obs;

  /// Make cfg reactive
  Rx<MapConfig> cfg = MapConfig(
    mapWidth: 279,
    mapHeight: 288,
    marginMeters: 20,
    pxPerMeter: 5.7,
  ).obs;
}
