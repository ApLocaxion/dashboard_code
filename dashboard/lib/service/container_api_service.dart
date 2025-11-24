import 'dart:convert';

import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/models/pose.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ContainerService {
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );

  getAllForklift() async {
    var response = await http.get(
      Uri.parse("${Constants.baseApiUrilocal}/api/last_position"),
      headers: {"Content-type": "Application/json"},
    );
    // if response is sucessful
    if (response.statusCode == 200) {
      containerController.containerList.clear();
      var data = jsonDecode(response.body);
      try {
        for (int i = 0; i < data.length; i++) {
          containerController.containerList.add(
            ContainerStateEventApiDTO.fromJson(data[i]),
          );
          print(containerController.containerList[0]);
        }
      } catch (e) {
        print(e);
      }
      //
    } else {
      CommonWidgets().errorSnackbar('Error', 'Unable to get Data from server');
    }
  }

  startSimulation() async {
    List<Pose> points = homePageController.simulatePoints
        .map((offset) => Pose(x: offset.dx, y: offset.dy, z: 1.1))
        .toList();
    homePageController.simulateDeviceId.value.isEmpty
        ? homePageController.simulateDeviceId.value =
              homePageController.deviceId.value
        : "";
    if (containerController.containerList.any(
      (c) => c.slamCoreId == homePageController.simulateDeviceId.value,
    )) {
      //
    } else {
      containerController.containerList.add(
        ContainerStateEventApiDTO(
          lastModified: DateTime.now().toString(),
          slamCoreId: homePageController.simulateDeviceId.value,
          x: points[0].x,
          y: points[0].y,
        ),
      );
    }

    final response = await http.post(
      Uri.parse("${Constants.baseApiUrilocal}/api/simulate"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "points": points,
        "deviceId": homePageController.simulateDeviceId.value,
      }),
    );

    // if response is sucessful
    if (response.statusCode == 200) {
      print("succes");
      //
    } else {
      CommonWidgets().errorSnackbar('Error', 'Unable to get Data from server');
    }
  }

  Future<void> getAllPosition({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url =
        "${Constants.baseApiUrilocal}/api/all_positions?deviceId=$deviceId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        containerController.trajectory.clear();

        for (var pos in data) {
          // if your DTO only supports x,y,z,timestamp, adjust accordingly
          containerController.trajectory.add(
            Pose(
              x: pos['x']?.toDouble() ?? 0.0,
              y: pos['y']?.toDouble() ?? 0.0,
              z: pos['z']?.toDouble() ?? 0.0,
            ),
          );
        }
        containerController.trajectory.refresh();

        print("✅ Loaded ${containerController.trajectory.length} positions");
      } else {
        CommonWidgets().errorSnackbar(
          'Error',
          'Unable to get data from server (${response.statusCode})',
        );
      }
    } catch (e) {
      print("❌ Error in getAllPosition: $e");
      CommonWidgets().errorSnackbar('Error', 'Something went wrong');
    }
  }
}
