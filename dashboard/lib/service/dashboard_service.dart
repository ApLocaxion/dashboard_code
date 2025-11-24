import 'dart:convert';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:http/http.dart' as http;

/// all functionality of dashboard
class DashboardService {
  //

  final dashboardController = Get.find<DashboardController>(
    tag: 'dashboardController',
  );

  getDashboard() async {
    // var response = await http.get(
    //   Uri.parse("${Constants.baseApiUrilocal}/api/bins"),
    //   headers: {"Content-type": "Application/json"},
    // );
    // // if response is sucessful
    // if (response.statusCode == 200) {
    //   var data = jsonDecode(response.body);
    //   try {
    //     for (int i = 0; i < data.length; i++) {
    //       //
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    //   //
    // } else {
    //   CommonWidgets().errorSnackbar(
    //     'Error',
    //     'Unable to get bin  Data from server',
    //   );
    // }
  }
}
