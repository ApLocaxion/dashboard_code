import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:get/get.dart';

class MarkerOverlay extends StatelessWidget {
  final MapConfig cfg;
  final double zoom;
  final Offset panPx;
  final List<ContainerStateEventApiDTO> containers;
  final List<BinModel> bins;

  /// If true, icon size is constant in screen pixels (doesn't scale with zoom).
  /// If false, icon size is multiplied by [zoom] (scales with map).
  final bool screenFixedSize;
  final double iconSize; // base size in logical pixels
  final void Function(ContainerStateEventApiDTO container)? onForkliftTap;

  MarkerOverlay({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.containers,
    required this.bins,
    this.onForkliftTap,
    this.iconSize = 24,
    this.screenFixedSize = true,
  });

  // ----- world extents (meters) with margins -----
  double get _originX => -cfg.marginMeters;
  double get _originY => -cfg.marginMeters;
  double get _worldWm => cfg.widthMeters + 2 * cfg.marginMeters;
  double get _worldHm => cfg.heightMeters + 2 * cfg.marginMeters;

  // pixels per meter at current zoom
  double get _scale => cfg.pxPerMeter * zoom;

  // Bottom-left origin mapping (X linear, Y flipped by total world height)
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * zoom + panPx.dx;
    final yImg = (ym - _originY) * zoom;
    final heightPx = _worldHm * zoom;
    final yPx = (heightPx - yImg) + panPx.dy; // flip Y
    return Offset(xPx, yPx);
  }

  // Optional visibility culling (meters) — keeps widget list smaller.
  Rect _visibleWorld(Size size) {
    final leftM = _originX + (-panPx.dx) / _scale;
    final rightM = leftM + size.width / _scale;

    final topM = _originY + _worldHm - ((0.0 - panPx.dy) / _scale);
    final bottomM = _originY + _worldHm - ((size.height - panPx.dy) / _scale);

    final l = leftM < rightM ? leftM : rightM;
    final r = leftM < rightM ? rightM : leftM;
    final b = bottomM < topM ? bottomM : topM;
    final t = bottomM < topM ? topM : bottomM;

    final bounds = Rect.fromLTWH(_originX, _originY, _worldWm, _worldHm);
    return Rect.fromLTRB(l, b, r, t).intersect(bounds);
  }

  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final vis = _visibleWorld(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          final children = <Widget>[];

          // Anchor image at world (0,0) with bottom-left alignment,
          // moving with pan/zoom like forklifts.
          final originPoint = Offset(0, 0);

          final p0 = _toScreen(originPoint.dx, originPoint.dy);
          final imgSize = 140.0 * zoom;
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

          // containers.add(
          //   ContainerStateEventApiDTO(
          //     lastModified: "2025-09-24T12:10:36.097182Z",
          //     slamCoreId: "1",
          //     x: 0.0,
          //     y: 10.0,
          //     z: 0.0,
          //   ),
          // );

          // Forklifts (containers)
          for (final c in containers) {
            final x = (c.x).toDouble();
            final y = (c.y).toDouble();
            if (x == 0 && y == 0) continue;
            if (x < _originX ||
                y < _originY ||
                x > _originX + _worldWm ||
                y > _originY + _worldHm) {
              continue;
            }
            // if (!vis.contains(Offset(x, y))) continue;

            final p = _toScreen(x, y);
            final sizePx = screenFixedSize ? iconSize : iconSize * zoom;

            children.add(
              // This ensures the widget center is exactly at p
              Positioned(
                left: p.dx - sizePx / 2,
                top: p.dy - sizePx / 2,
                width: sizePx,
                height: sizePx,
                child: RepaintBoundary(
                  child: GestureDetector(
                    onTap: () {
                      c;
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Obx(
                      () => Icon(
                        Icons.location_on_outlined,
                        color: webSocketController.isConnected.value
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            );

            // Optional label next to the marker
            if ((c.slamCoreId).isNotEmpty) {
              children.add(
                Positioned(
                  left: p.dx + 5,
                  top: p.dy + 4,
                  child: IgnorePointer(
                    child: Text(
                      c.slamCoreId,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          /// change bin icon size * zoom
          ///
          // Bins
          for (final b in bins) {
            final x = (b.x);
            final y = (b.y);
            if (x == 0 && y == 0) continue;
            if (x < _originX ||
                y < _originY ||
                x > _originX + _worldWm ||
                y > _originY + _worldHm) {
              continue;
            }
            if (!vis.contains(Offset(x, y))) continue;

            final p = _toScreen(x, y);
            final sizePx = screenFixedSize ? iconSize : iconSize * zoom;

            children.add(
              Positioned(
                left: p.dx - sizePx / 2,
                top: p.dy - sizePx / 2,
                width: sizePx,
                height: sizePx,
                child: IconButton(
                  icon: Icon(
                    Icons.inventory_2,
                    color: b.status == 'load' ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        //
                        return Stack(
                          children: [
                            Positioned(
                              left: 50,
                              top: 50,
                              child: Material(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      20.0,
                                    ), //
                                  ),
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            19,
                                            90,
                                            148,
                                          ),
                                        ),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Bin id: ${b.binId}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          b.zoneCode != null
                                              ? "Location : ${b.zoneCode}"
                                              : "Location : NA",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          'Forklift : ${b.forkliftId}',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Text(
                                          'Weight : NA',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        color: Colors.red,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                'MixGrade  : g1,g2,g4',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    //
                    // print(b);
                  },
                ),
              ),
            );

            if (b.binId.isNotEmpty) {
              children.add(
                Positioned(
                  left: p.dx + 5,
                  top: p.dy + 4,
                  child: Material(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          // <-- background color
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          b.binId,
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          return Stack(clipBehavior: Clip.none, children: children);
        },
      ),
    );
  }
}
