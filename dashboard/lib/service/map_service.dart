import 'dart:convert';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MapService {
  final mapController = Get.find<MapController>(tag: 'mapController');

  Future<void> loadMapConfig() async {
    try {
      final response = await http.get(
        Uri.parse("${Constants.baseApiUrilocal}/api/map_config"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _applyConfig(data);
      } else {
        CommonWidgets().errorSnackbar(
          'Error',
          'Unable to fetch map config from server',
        );
      }
    } catch (e) {
      CommonWidgets().errorSnackbar('Error', 'Unable to fetch map config');
    }
  }

  Future<bool> updatePxPerMeter(double value) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.baseApiUrilocal}/api/map_config"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pxPerMeter": value}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _applyConfig(data);
        return true;
      } else {
        CommonWidgets().errorSnackbar(
          'Error',
          'Unable to update map config (${response.statusCode})',
        );
        return false;
      }
    } catch (e) {
      CommonWidgets().errorSnackbar('Error', 'Unable to update map config');
      return false;
    }
  }

  void _applyConfig(Map<String, dynamic> json) {
    final current = mapController.cfg.value;

    final double newPxPerMeter =
        (json['pxPerMeter'] as num?)?.toDouble() ?? current.pxPerMeter;

    // Keep the physical map size (meters) in sync with the new scale so
    // the SVG and layers resize immediately when pxPerMeter changes.
    double newMapWidth = current.mapWidth;
    double newMapHeight = current.mapHeight;
    if (current.pxPerMeter > 0 && newPxPerMeter > 0) {
      final scale = current.pxPerMeter / newPxPerMeter;
      newMapWidth = current.mapWidth * scale;
      newMapHeight = current.mapHeight * scale;
    }

    MapConfig updated = current.copyWith(
      pxPerMeter: newPxPerMeter,
      mapWidth: newMapWidth,
      mapHeight: newMapHeight,
    );
    mapController.cfg.value = updated;
    mapController.cfg.refresh();
  }
}
