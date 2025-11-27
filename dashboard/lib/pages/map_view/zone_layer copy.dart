import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/pose.dart';
import 'package:dashboard/models/zone_model.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZoneLayer2 extends StatefulWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;

  const ZoneLayer2({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    this.minorStepM = 1,
    this.majorStepM = 10,
    this.showLabels = true,
  });

  @override
  State<ZoneLayer2> createState() => _ZoneLayer2State();
}

class _ZoneLayer2State extends State<ZoneLayer2> {
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );

  String? _hoveredCode;
  Offset? _hoverPos;

  double get _originX => -widget.cfg.marginMeters;
  double get _originY => -widget.cfg.marginMeters;
  double get _worldHm => widget.cfg.heightMeters + 2 * widget.cfg.marginMeters;

  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * widget.zoom + widget.panPx.dx;
    final yImg = (ym - _originY) * widget.zoom;
    final heightPx = _worldHm * widget.zoom;
    final yPx = (heightPx - yImg) + widget.panPx.dy; // flip Y
    return Offset(xPx, yPx);
  }

  Path _zonePath(ZoneModel zone) {
    final path = Path();
    for (int i = 0; i < zone.boundary.length; i++) {
      double x = zone.boundary[i]['x'];
      double y = zone.boundary[i]['y'];
      final p = _toScreen(x, y);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  void _updateHover(Offset localPos) {
    String? code;
    for (final zone in zoneController.allZone) {
      if (_isOnZoneEdge(zone, localPos)) {
        code = zone.code;
        break;
      }
    }
    if (code != _hoveredCode || _hoverPos != localPos) {
      setState(() {
        _hoveredCode = code;
        _hoverPos = code == null ? null : localPos;
      });
    }
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ap = p - a;
    final ab = b - a;
    final t = (ap.dx * ab.dx + ap.dy * ab.dy) / (ab.dx * ab.dx + ab.dy * ab.dy);
    final clamped = t.clamp(0.0, 1.0);
    final closest = Offset(a.dx + ab.dx * clamped, a.dy + ab.dy * clamped);
    return (p - closest).distance;
  }

  bool _isOnZoneEdge(ZoneModel zone, Offset pos, {double tol = 6}) {
    final points = zone.boundary
        .map<Offset>((p) => _toScreen(p['x'], p['y']))
        .toList(growable: false);
    if (points.length < 2) return false;
    for (int i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      if (_distToSegment(pos, a, b) <= tol) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = containerController.trajectory.length;
      final __ = zoneController.allZone.length;
      final ___ = containerController.showTrajector.value;

      return MouseRegion(
        onHover: (event) => _updateHover(event.localPosition),
        onExit: (_) => setState(() {
          _hoveredCode = null;
          _hoverPos = null;
        }),
        child: SizedBox.expand(
          child: Stack(
            children: [
              CustomPaint(
                painter: _ZoneLayer2(
                  cfg: widget.cfg,
                  zoom: widget.zoom,
                  panPx: widget.panPx,
                  minorStepM: widget.minorStepM,
                  majorStepM: widget.majorStepM,
                  showLabels: widget.showLabels,
                  devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
                  allZone: zoneController.allZone,
                  trajectory: containerController.trajectory,
                  toScreen: _toScreen,
                ),
              ),
              if (_hoveredCode != null && _hoverPos != null)
                Positioned(
                  left: _hoverPos!.dx + 10,
                  top: _hoverPos!.dy + 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        _hoveredCode!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _ZoneLayer2 extends CustomPainter {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx; // screen-space pan (pixels)
  final double minorStepM;
  final double majorStepM;
  final bool showLabels;
  List<Pose> trajectory;
  final double devicePixelRatio;
  List<ZoneModel> allZone;
  final Offset Function(double xm, double ym) toScreen;

  _ZoneLayer2({
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.minorStepM,
    required this.trajectory,
    required this.majorStepM,
    required this.showLabels,
    required this.allZone,
    required this.devicePixelRatio,
    required this.toScreen,
  });

  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (containerController.showTrajector.value) {
      final Path trajectoryPath = Path();
      if (trajectory.isNotEmpty) {
        var p = toScreen(trajectory[0].x, trajectory[0].y);
        trajectoryPath.moveTo(p.dx, p.dy);
      }
      for (int i = 1; i < trajectory.length; i++) {
        var p = toScreen(trajectory[i].x, trajectory[i].y);
        trajectoryPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        trajectoryPath,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
    // Mark the world origin with a small cross and label so the zero point is easy to spot.
    final Offset origin = toScreen(0, 0);
    const double tick = 16.0;
    final Path originPath = Path()
      ..moveTo(origin.dx - tick, origin.dy)
      ..lineTo(origin.dx + tick, origin.dy)
      ..moveTo(origin.dx, origin.dy - tick)
      ..lineTo(origin.dx, origin.dy + tick);

    canvas.drawPath(
      originPath,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final Offset origin2 = toScreen(50, 50);
    final Path originPath2 = Path()
      ..moveTo(origin2.dx - tick, origin2.dy)
      ..lineTo(origin2.dx + tick, origin2.dy)
      ..moveTo(origin2.dx, origin2.dy - tick)
      ..lineTo(origin2.dx, origin2.dy + tick);

    canvas.drawPath(
      originPath2,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '0,0',
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, origin + Offset(8, -textPainter.size.height - 2));

    try {
      for (int z = 0; z < allZone.length; z++) {
        final Path path = Path();
        for (int i = 0; i < allZone[z].boundary.length; i++) {
          double x = allZone[z].boundary[i]['x'];
          double y = allZone[z].boundary[i]['y'];
          final p = toScreen(x, y);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = const ui.Color.fromARGB(255, 182, 11, 63)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneLayer2 old) {
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
