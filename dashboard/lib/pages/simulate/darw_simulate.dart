import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/pose.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimulationLayer extends StatelessWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;

  SimulationLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    this.minorStepM = 1,
    this.majorStepM = 10,
    this.showLabels = true,
  });

  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = homePageController..simulatePoints.length;

      return CustomPaint(
        painter: _SimulationLayer(
          cfg: cfg,
          zoom: zoom,
          panPx: panPx,
          minorStepM: minorStepM,
          majorStepM: majorStepM,
          showLabels: showLabels,
          devicePixelRatio: MediaQuery.of(context).devicePixelRatio,

          simulaionTrajectory: homePageController.simulatePoints,
        ),
      );
    });
  }
}

class _SimulationLayer extends CustomPainter {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx; // screen-space pan (pixels)
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;
  List<Offset> simulaionTrajectory;
  final double devicePixelRatio;

  _SimulationLayer({
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.minorStepM,
    required this.simulaionTrajectory,
    required this.majorStepM,
    required this.showLabels,
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
    //
    final Path simlationPath = Path();

    if (simulaionTrajectory.isNotEmpty) {
      var p = _toScreen(simulaionTrajectory[0].dx, simulaionTrajectory[0].dy);
      simlationPath.moveTo(p.dx, p.dy);
      canvas.drawCircle(Offset(p.dx, p.dy), 1, Paint()..color = Colors.red);
    }

    for (int i = 1; i < simulaionTrajectory.length; i++) {
      var p = _toScreen(simulaionTrajectory[i].dx, simulaionTrajectory[i].dy);
      simlationPath.lineTo(p.dx, p.dy);
      canvas.drawCircle(Offset(p.dx, p.dy), 1, Paint()..color = Colors.red);
    }

    canvas.drawPath(
      simlationPath,
      Paint()
        ..color = const ui.Color.fromARGB(255, 233, 108, 99)
        ..style = PaintingStyle
            .stroke // Or PaintingStyle.fill for a filled pentagon
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant _SimulationLayer old) {
    return old.zoom != zoom ||
        old.panPx != panPx ||
        old.minorStepM != minorStepM ||
        old.majorStepM != majorStepM ||
        old.cfg != cfg ||
        old.showLabels != showLabels ||
        old.simulaionTrajectory != simulaionTrajectory;
  }
}
