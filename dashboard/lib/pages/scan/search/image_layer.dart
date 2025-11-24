import 'package:flutter/material.dart';
import 'package:dashboard/pages/map_view/map_config.dart';

class ImageLayer extends StatefulWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;

  const ImageLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
  });

  @override
  State<ImageLayer> createState() => _ImageLayerState();
}

class _ImageLayerState extends State<ImageLayer> {
  // ----- world extents (meters) with margins -----
  double get _originX => -widget.cfg.marginMeters;
  double get _originY => -widget.cfg.marginMeters;
  double get _worldHm => widget.cfg.heightMeters + 2 * widget.cfg.marginMeters;

  // Bottom-left origin mapping (X linear, Y flipped by total world height)
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * widget.zoom + widget.panPx.dx;
    final yImg = (ym - _originY) * widget.zoom;
    final heightPx = _worldHm * widget.zoom;
    final yPx = (heightPx - yImg) + widget.panPx.dy; // flip Y
    return Offset(xPx, yPx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final children = <Widget>[];
        final originPoint = Offset(0, 0);
        final p0 = _toScreen(originPoint.dx, originPoint.dy);
        final imgSize = 140.0 * widget.zoom;
        children.add(
          Positioned(
            left: p0.dx,
            top: p0.dy - imgSize, // bottom-left of image at (0,0)
            width: imgSize,
            height: imgSize,
            child: const IgnorePointer(
              child: Image(
                // image: AssetImage('assets/rt.png'),
                // image: AssetImage('assets/rb.jpg'),
                image: AssetImage('assets/map.jpg'),
                opacity: AlwaysStoppedAnimation(1),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        );

        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}
