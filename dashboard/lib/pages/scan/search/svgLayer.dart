import 'package:dashboard/common/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dashboard/pages/map_view/map_config.dart';

class SvgLayer extends StatefulWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;

  const SvgLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
  });

  @override
  State<SvgLayer> createState() => _SvgLayerState();
}

class _SvgLayerState extends State<SvgLayer> {
  double get _originX => -widget.cfg.marginMeters;
  double get _originY => -widget.cfg.marginMeters;
  double get _worldHm => widget.cfg.heightMeters + 2 * widget.cfg.marginMeters;

  // Convert world → screen (bottom-left origin)
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * widget.zoom + widget.panPx.dx;
    final yImg = (ym - _originY) * widget.zoom;
    final heightPx = _worldHm * widget.zoom;
    final yPx = (heightPx - yImg) + widget.panPx.dy;
    return Offset(xPx, yPx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final children = <Widget>[];

        final p0 = _toScreen(0, 0);
        final imgWidth = Env.cfg.heightMeters * widget.zoom;
        final imgHeight = Env.cfg.widthMeters * widget.zoom;

        children.add(
          Positioned(
            left: p0.dx,
            top: p0.dy - imgWidth,
            width: imgWidth,
            height: imgHeight,
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/ELVAL_SVG1.svg',
                fit: BoxFit.contain,

                // ******** SHOW LOADER WHILE SVG IS LOADING ********
                placeholderBuilder: (context) => Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        );

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}
