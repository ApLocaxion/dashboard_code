import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:flutter/material.dart';

class GridLayer extends StatelessWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;

  const GridLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    this.minorStepM = 1,
    this.majorStepM = 10,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        cfg: cfg,
        zoom: zoom,
        panPx: panPx,
        minorStepM: minorStepM,
        majorStepM: majorStepM,
        showLabels: showLabels,
        devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx; // screen-space pan (pixels)
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;
  final double devicePixelRatio;

  _GridPainter({
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.minorStepM,
    required this.majorStepM,
    required this.showLabels,
    required this.devicePixelRatio,
  });

  // ===== Fixed world extents (meters) =====
  double get originX => -cfg.marginMeters;
  double get originY => -cfg.marginMeters;

  // Pixels per meter at current zoom
  double get scale => cfg.pxPerMeter * zoom;

  // For crisp 1px strokes
  double _pixelSnap(double v) => (v.floorToDouble()) + 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    // Paints
    final minorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFEEEEEE);

    final majorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFCCCCCC);

    // Compute step sizes in pixels
    final double minorStepPx = minorStepM * scale;
    final double majorStepPx = majorStepM * scale;

    // Start/end indices (k) for lines in screen space where x = panPx.dx + k*minorStepPx
    // k=0 corresponds to world x=0 aligned line.
    int startKx = ((0 - panPx.dx) / minorStepPx).floor();
    int endKx = ((size.width - panPx.dx) / minorStepPx).ceil();
    int startKy = ((0 - panPx.dy) / minorStepPx).floor();
    int endKy = ((size.height - panPx.dy) / minorStepPx).ceil();

    // Major every N minor steps (if ratio is integral)
    final double majorEveryD = (majorStepPx / minorStepPx);
    final bool majorIsIntegral =
        (majorEveryD % 1.0) == 0.0 && majorEveryD.isFinite;
    final int majorEvery = majorIsIntegral ? majorEveryD.toInt() : 0;

    // Draw vertical grid lines
    for (int i = startKx; i <= endKx; i++) {
      final xPx = _pixelSnap(panPx.dx + i * minorStepPx);
      final bool isMajor = majorIsIntegral ? (i % majorEvery == 0) : false;
      canvas.drawLine(
        Offset(xPx, 0),
        Offset(xPx, size.height),
        isMajor ? majorPaint : minorPaint,
      );
    }

    // Draw horizontal grid lines
    for (int j = startKy; j <= endKy; j++) {
      final yPx = _pixelSnap(panPx.dy + j * minorStepPx);
      final bool isMajor = majorIsIntegral ? (j % majorEvery == 0) : false;
      canvas.drawLine(
        Offset(0, yPx),
        Offset(size.width, yPx),
        isMajor ? majorPaint : minorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) {
    return old.zoom != zoom ||
        old.panPx != panPx ||
        old.minorStepM != minorStepM ||
        old.majorStepM != majorStepM ||
        old.cfg != cfg ||
        old.showLabels != showLabels;
  }
}
