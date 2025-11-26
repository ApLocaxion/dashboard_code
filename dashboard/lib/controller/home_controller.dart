import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  final isWorking = true.obs;

  final scan = true.obs;
  final manualEntry = false.obs;
  final simulatePoints = <Offset>[].obs;
  final recordPoints = false.obs;

  final RxString simulateDeviceId = "".obs;
  final RxString deviceId = "FORKLIFT-001".obs;
  // final RxString deviceId = "FORKLIFT-001".obs;

  change() {
    isWorking.value = false;
  }
}
