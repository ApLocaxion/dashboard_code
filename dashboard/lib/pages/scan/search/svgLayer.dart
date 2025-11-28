import 'package:dashboard/common/env.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xml/xml.dart';
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
  double get _worldHm => widget.cfg.mapHeight + 2 * widget.cfg.marginMeters;

  // Convert world → screen (bottom-left origin)
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * widget.zoom + widget.panPx.dx;
    final yImg = (ym - _originY) * widget.zoom;
    final heightPx = _worldHm * widget.zoom;
    final yPx = (heightPx - yImg) + widget.panPx.dy;
    return Offset(xPx, yPx);
  }

  final mapController = Get.find<MapController>(tag: 'mapController');

  Future getSvgIntrinsicSize() async {
    final svgString = await rootBundle.loadString(
      'assets/ELVAL_SVG1-NOWHITESPACE2.svg',
    );
    final doc = XmlDocument.parse(svgString);
    final svgElem = doc.rootElement;

    double width = double.tryParse(svgElem.getAttribute('width') ?? '') ?? 0;
    double height = double.tryParse(svgElem.getAttribute('height') ?? '') ?? 0;

    width = width / mapController.cfg.value.pxPerMeter;
    height = height / mapController.cfg.value.pxPerMeter;

    // Create a new MapConfig and assign it
    mapController.cfg.value = mapController.cfg.value.copyWith(
      mapWidth: width,
      mapHeight: height,
    );
    mapController.cfg.refresh();
  }

  @override
  void initState() {
    super.initState();
    ////cc
    getSvgIntrinsicSize();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final children = <Widget>[];

        final p0 = _toScreen(0, 0);
        final imgWidth = mapController.cfg.value.mapWidth * widget.zoom;
        final imgHeight = mapController.cfg.value.mapHeight * widget.zoom;

        children.add(
          Positioned(
            left: p0.dx,
            top: p0.dy - imgHeight,
            width: imgWidth,
            height: imgHeight,
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/ELVAL_SVG1-NOWHITESPACE2.svg',
                // 'assets/ELVAL_SVG1-NOWHITESPACE2.svg',
                fit: BoxFit.contain,
                alignment: AlignmentGeometry.bottomLeft,

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
