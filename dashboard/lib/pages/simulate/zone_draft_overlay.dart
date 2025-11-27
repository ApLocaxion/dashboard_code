import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:flutter/material.dart';

class ZoneDraftOverlay extends StatelessWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final List<Offset> zonePoints;

  const ZoneDraftOverlay({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.zonePoints,
  });

  @override
  Widget build(BuildContext context) {
    if (zonePoints.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _ZoneDraftPainter(
        cfg: cfg,
        zoom: zoom,
        panPx: panPx,
        zonePoints: zonePoints,
      ),
    );
  }
}

class _ZoneDraftPainter extends CustomPainter {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final List<Offset> zonePoints;

  _ZoneDraftPainter({
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.zonePoints,
  });

  double get originX => -cfg.marginMeters;
  double get originY => -cfg.marginMeters;
  double get worldHm => cfg.mapHeight + 2 * cfg.marginMeters;

  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - originX) * zoom + panPx.dx;
    final yImg = (ym - originY) * zoom;
    final heightPx = worldHm * zoom;
    final yPx = (heightPx - yImg) + panPx.dy;
    return Offset(xPx, yPx);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (zonePoints.isEmpty) return;

    final screenPoints = zonePoints.map((p) => _toScreen(p.dx, p.dy)).toList();
    final outlinePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    if (screenPoints.length >= 2) {
      final path = Path()..moveTo(screenPoints.first.dx, screenPoints.first.dy);
      for (var i = 1; i < screenPoints.length; i++) {
        path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
      }
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, outlinePaint);
    }

    for (final p in screenPoints) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneDraftPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panPx != panPx ||
        oldDelegate.zonePoints != zonePoints ||
        oldDelegate.cfg != cfg;
  }
}
