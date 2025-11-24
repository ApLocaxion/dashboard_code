import 'dart:convert';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// this handle all bin functionality
class BinService {
  ///
  final binController = Get.find<BinController>(tag: 'binController');

  /// get all bin
  getAllBin() async {
    var response = await http.get(
      Uri.parse("${Constants.baseApiUrilocal}/api/bins"),
      headers: {"Content-type": "Application/json"},
    );
    // if response is sucessful
    if (response.statusCode == 200) {
      binController.allBin.clear();
      var data = jsonDecode(response.body);
      try {
        for (int i = 0; i < data.length; i++) {
          binController.allBin.add(BinModel.fromJson(data[i]));
        }
        binController.allBin;
      } catch (e) {
        print(e);
      }
      //
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to get bin  Data from server',
      );
    }
  }

  //
  loadBin(
    String binId,
    String status, {
    String deviceId = "FORKLIFT-001",
  }) async {
    try {
      // bin id khali mt chod
      var response = await http.post(
        Uri.parse("${Constants.baseApiUrilocal}/api/bins"),
        headers: {
          "Content-Type": "application/json", // important!
        },
        body: jsonEncode({
          "binId": binId,
          "forkliftId": deviceId,
          "status": status,
        }),
      );
      // if response is sucessful
      if (response.statusCode == 200) {
        //
      } else {
        CommonWidgets().errorSnackbar(
          'Error',
          'Unable to get bin  Data from server',
        );
      }
    } catch (e) {
      print(e);
    }
  }

  ///  change status load-unload
}
