import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/pose.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZoneLayer extends StatelessWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;

  ZoneLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    this.minorStepM = 1,
    this.majorStepM = 10,
    this.showLabels = true,
  });
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');

  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = containerController.trajectory.length;
      final _ = zoneController.allZone.length;
      final _ = containerController.showTrajector.value;
      return CustomPaint(
        painter: _ZoneLayer(
          cfg: cfg,
          zoom: zoom,
          panPx: panPx,
          minorStepM: minorStepM,
          majorStepM: majorStepM,
          showLabels: showLabels,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
          allZone: zoneController.allZone,
          trajectory: containerController.trajectory,
        ),
      );
    });
  }
}

class _ZoneLayer extends CustomPainter {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx; // screen-space pan (pixels)
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;
  List<Pose> trajectory;
  final double devicePixelRatio;
  List<ZoneModel> allZone;

  _ZoneLayer({
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.minorStepM,
    required this.trajectory,
    required this.majorStepM,
    required this.showLabels,
    required this.allZone,
    required this.devicePixelRatio,
  });

  // ===== Fixed world extents (meters) =====
  double get originX => -cfg.marginMeters;
  double get originY => -cfg.marginMeters;
  double get worldWm => cfg.widthMeters + 2 * cfg.marginMeters;
  double get worldHm => cfg.heightMeters + 2 * cfg.marginMeters;

  // Pixels per meter at current zoom
  double get scale => cfg.pxPerMeter * zoom;

  // World (m) -> Screen (px)
  double worldXToScreen(double xm) => (xm * scale) + panPx.dx;
  double worldYToScreen(double ym) => (ym * scale) + panPx.dy;
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );

  //
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - originX) * zoom + panPx.dx;
    final yImg = (ym - originY) * zoom;
    final heightPx = worldHm * zoom;
    final yPx = (heightPx - yImg) + panPx.dy; // flip Y
    return Offset(xPx, yPx);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (containerController.showTrajector.value) {
      //
      final Path trajectoryPath = Path();

      if (trajectory.isNotEmpty) {
        var p = _toScreen(trajectory[0].x, trajectory[0].y);
        trajectoryPath.moveTo(p.dx, p.dy);
      }

      for (int i = 1; i < trajectory.length; i++) {
        var p = _toScreen(trajectory[i].x, trajectory[i].y);
        trajectoryPath.lineTo(p.dx, p.dy);
      }

      canvas.drawPath(
        trajectoryPath,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle
              .stroke // Or PaintingStyle.fill for a filled pentagon
          ..strokeWidth = 1.0,
      );
    }

    try {
      //
      for (int z = 0; z < allZone.length; z++) {
        final Path path = Path();

        // Calculate the vertices of the pentagon
        for (int i = 0; i < allZone[z].boundary.length; i++) {
          double x = allZone[z].boundary[i]['x'];
          double y = allZone[z].boundary[i]['y'];
          var p = _toScreen(x, y);
          x = p.dx;
          y = p.dy;

          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = const ui.Color.fromARGB(255, 182, 11, 63)
            ..style = PaintingStyle
                .stroke // Or PaintingStyle.fill for a filled pentagon
            ..strokeWidth = 3.0,
        );

        // path.
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneLayer old) {
    return old.zoom != zoom ||
        old.panPx != panPx ||
        old.minorStepM != minorStepM ||
        old.majorStepM != majorStepM ||
        old.cfg != cfg ||
        old.showLabels != showLabels ||
        old.allZone != allZone ||
        old.trajectory != trajectory;
  }
}
