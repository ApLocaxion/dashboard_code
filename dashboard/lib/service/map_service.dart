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
        CommonWidgets()
            .errorSnackbar('Error', 'Unable to fetch map config from server');
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
    final updated = MapConfig(
      mapWidth: _asDouble(json['mapWidth'], current.mapWidth),
      mapHeight: _asDouble(json['mapHeight'], current.mapHeight),
      marginMeters: _asDouble(json['marginMeters'], current.marginMeters),
      pxPerMeter: _asDouble(json['pxPerMeter'], current.pxPerMeter),
    );
    mapController.cfg.value = updated;
    mapController.cfg.refresh();
  }

  double _asDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }
}
