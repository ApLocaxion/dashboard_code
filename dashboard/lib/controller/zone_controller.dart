import 'package:dashboard/models/zone-event.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:get/get.dart';

class ZoneController extends GetxController {
  final RxList<ZoneModel> allZone = <ZoneModel>[].obs;
  final RxList<ZoneEventModel> allZoneEvent = <ZoneEventModel>[].obs;
  RxnString hoveredZoneName = RxnString();

  RxDouble x = RxDouble(0);
  RxDouble y = RxDouble(0);
}
