import 'dart:convert';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/zone-event.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ZoneService {
  //
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');

  //
  getAllZone() async {
    var response = await http.get(
      Uri.parse("${Constants.baseApiUrilocal}/api/zones"),
    );
    // if response is sucessful
    if (response.statusCode == 200) {
      try {
        zoneController.allZone.clear();
        var data = jsonDecode(response.body);
        for (int i = 0; i < data.length; i++) {
          zoneController.allZone.add(ZoneModel.fromJson(data[i]));
        }
      } catch (e) {
        print(e);
      }

      //
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to get zone  Data from server',
      );
    }
  }

  getAllzoneEvents() async {
    var response = await http.get(
      Uri.parse("${Constants.baseApiUrilocal}/api/zone_events"),
    );
    // if response is sucessful
    if (response.statusCode == 200) {
      try {
        zoneController.allZoneEvent.clear();
        var data = jsonDecode(response.body);
        for (int i = 0; i < data.length; i++) {
          zoneController.allZoneEvent.add(ZoneEventModel.fromJson(data[i]));
        }
      } catch (e) {
        print(e);
      }

      //
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to get zone  Data from server',
      );
    }
  }
}
