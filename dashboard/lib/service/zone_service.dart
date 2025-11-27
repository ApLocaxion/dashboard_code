import 'dart:convert';
import 'dart:ui';
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

  Future<int?> createZone({
    required String code,
    required List<Offset> boundary,
  }) async {
    if (code.trim().isEmpty) {
      CommonWidgets().errorSnackbar('Error', 'Enter a zone code');
      return null;
    }

    if (boundary.length < 4) {
      CommonWidgets().errorSnackbar(
        'Error',
        'Draw a rectangle on the map first',
      );
      return null;
    }

    final closedBoundary = <Offset>[...boundary];
    if (closedBoundary.first != closedBoundary.last) {
      closedBoundary.add(closedBoundary.first);
    }

    final polygon = closedBoundary
        .map(
          (p) => "${p.dx.toStringAsFixed(1)} ${p.dy.toStringAsFixed(1)}",
        )
        .join(", ");

    final zoneId = DateTime.now().millisecondsSinceEpoch;
    final payload = {
      "zoneId": zoneId,
      "code": code.trim(),
      "hasChild": false,
      "chlidId": <int>[],
      "active": true,
      "title": code.trim(),
      "description": "Zone $code",
      "boundary": "POLYGON (($polygon))",
      "zmax": 100.0,
      "zmin": -1.0,
    };

    final response = await http.post(
      Uri.parse("${Constants.baseApiUrilocal}/api/zones"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getAllZone();
      Get.snackbar(
        'Zone created',
        'Zone ${code.trim()} saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return zoneId;
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to create zone (${response.statusCode})',
      );
      return null;
    }
  }

  Future<void> updateZoneChildren({
    required ZoneModel zone,
    required List<int> childIds,
  }) async {
    final uniqueChildren = childIds.toSet().toList();
    final boundary = _boundaryToWkt(zone.boundary);

    final payload = {
      "zoneId": zone.zoneId,
      "code": zone.code,
      "hasChild": uniqueChildren.isNotEmpty,
      "chlidId": uniqueChildren,
      "active": zone.active,
      "title": zone.title,
      "description": zone.description,
      "boundary": boundary,
      "zmax": zone.zMax,
      "zmin": zone.zMin,
    };

    final response = await http.post(
      Uri.parse("${Constants.baseApiUrilocal}/api/zones"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await getAllZone();
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to update zone children (${response.statusCode})',
      );
    }
  }

  String _boundaryToWkt(List boundary) {
    final points = <String>[];
    for (var p in boundary) {
      final xVal = p['x'] ?? p['X'] ?? 0;
      final yVal = p['y'] ?? p['Y'] ?? 0;
      final x = (xVal is num) ? xVal.toDouble() : double.tryParse("$xVal") ?? 0;
      final y = (yVal is num) ? yVal.toDouble() : double.tryParse("$yVal") ?? 0;
      points.add("${x.toStringAsFixed(1)} ${y.toStringAsFixed(1)}");
    }
    if (points.isEmpty) return "";
    if (points.first != points.last) {
      points.add(points.first);
    }
    return "POLYGON ((${points.join(", ")}))";
  }
}
