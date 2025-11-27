import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/pages/map_view/map_config.dart';
import 'package:get/get.dart';

/// show text only after certain zoom level
class MarkerLayer extends StatefulWidget {
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

  const MarkerLayer({
    super.key,
    required this.cfg,
    required this.zoom,
    required this.panPx,
    required this.containers,
    required this.bins,
    this.onForkliftTap,
    this.iconSize = 20,
    this.screenFixedSize = true,
  });

  @override
  State<MarkerLayer> createState() => _MarkerLayerState();
}

class _MarkerLayerState extends State<MarkerLayer> {
  // ----- world extents (meters) with margins -----
  double get _originX => -widget.cfg.marginMeters;
  double get _originY => -widget.cfg.marginMeters;
  double get _worldWm => widget.cfg.widthMeters + 2 * widget.cfg.marginMeters;
  double get _worldHm => widget.cfg.heightMeters + 2 * widget.cfg.marginMeters;

  // pixels per meter at current zoom
  double get _scale => widget.cfg.pxPerMeter * widget.zoom;

  // Bottom-left origin mapping (X linear, Y flipped by total world height)
  Offset _toScreen(double xm, double ym) {
    final xPx = (xm - _originX) * widget.zoom + widget.panPx.dx;
    final yImg = (ym - _originY) * widget.zoom;
    final heightPx = _worldHm * widget.zoom;
    final yPx = (heightPx - yImg) + widget.panPx.dy; // flip Y
    return Offset(xPx, yPx);
  }

  // Optional visibility culling (meters) — keeps widget list smaller.
  Rect _visibleWorld(Size size) {
    final leftM = _originX + (-widget.panPx.dx) / _scale;
    final rightM = leftM + size.width / _scale;

    final topM = _originY + _worldHm - ((0.0 - widget.panPx.dy) / _scale);
    final bottomM =
        _originY + _worldHm - ((size.height - widget.panPx.dy) / _scale);

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

  final binController = Get.find<BinController>(tag: 'binController');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // trigger rebuild on selection change
      final _ = binController.selectedBinForDetail.value;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          _handleTap(details.localPosition);
        },
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final vis = _visibleWorld(
              Size(constraints.maxWidth, constraints.maxHeight),
            );
            final children = <Widget>[];

            // Forklifts (containers)
            for (final c in widget.containers) {
              final x = c.x.toDouble();
              final y = c.y.toDouble();
              if (x == 0 && y == 0) continue;
              if (x < _originX ||
                  y < _originY ||
                  x > _originX + _worldWm ||
                  y > _originY + _worldHm) {
                continue;
              }
              // Optionally use visibility culling:
              // if (!vis.contains(Offset(x, y))) continue;

              final p = _toScreen(x, y);
              final sizePx = widget.screenFixedSize
                  ? widget.iconSize
                  : widget.iconSize * widget.zoom;

              children.add(
                Positioned(
                  left: p.dx - sizePx / 2,
                  top: p.dy - sizePx / 2,
                  width: 30,
                  height: 30,
                  child: RepaintBoundary(
                    child: Image(
                      image: const AssetImage('assets/fu.png'),
                      opacity: const AlwaysStoppedAnimation(1),
                      color: Colors.orangeAccent,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                ),
              );

              // Optional label next to the marker
              if (c.slamCoreId.isNotEmpty) {
                children.add(
                  Positioned(
                    left: p.dx - 10,
                    top: p.dy + 15,
                    child: const IgnorePointer(
                      child: Text(
                        // using c.slamCoreId
                        '',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }

            // Bins
            for (final b in widget.bins) {
              final x = b.x;
              final y = b.y;
              if (x == 0 && y == 0) continue;
              if (x < _originX ||
                  y < _originY ||
                  x > _originX + _worldWm ||
                  y > _originY + _worldHm) {
                continue;
              }
              if (!vis.contains(Offset(x, y))) continue;

              final isSelected =
                  binController.selectedBin.value?.binId == b.binId;

              final p = _toScreen(x, y);
              final sizePx = widget.screenFixedSize
                  ? widget.iconSize
                  : widget.iconSize * widget.zoom;

              // Selection highlight
              if (isSelected) {
                final highlightSize = sizePx * 2.5;
                children.add(
                  Positioned(
                    left: p.dx - highlightSize / 2 + 5,
                    top: p.dy - highlightSize / 2 + 5,
                    width: highlightSize,
                    height: highlightSize,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Bin icon (no GestureDetector here)
              children.add(
                Positioned(
                  left: p.dx - sizePx / 2,
                  top: p.dy - sizePx / 2,
                  width: sizePx,
                  height: sizePx,
                  child: Icon(
                    Icons.inventory_2,
                    color: b.status == 'load' ? Colors.blue : Colors.grey,
                  ),
                ),
              );

              // Bin label (only after certain zoom level)
              if (b.binId.isNotEmpty && widget.zoom >= 15) {
                children.add(
                  Positioned(
                    left: p.dx - 5,
                    top: p.dy + 17,
                    child: Material(
                      color: Colors.transparent,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
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

            // Side detail card (only once, not inside the loop)
            final selectedDetail = binController.selectedBinForDetail.value;
            if (selectedDetail != null) {
              children.add(
                Positioned(
                  right: 20,
                  top: 10,
                  child: SizedBox(
                    width: 200,
                    child: CommonUi().appCard(
                      context: context,
                      child: Column(
                        children: [
                          Text(
                            selectedDetail.binId,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(),
                          CommonUi().detailRow(
                            "Location :",
                            selectedDetail.zoneCode != null
                                ? "${selectedDetail.zoneCode}"
                                : "N/A",
                            Theme.of(context).colorScheme,
                          ),
                          CommonUi().horizontalDivider(height: 6),
                          CommonUi().detailRow(
                            "Forklift :",
                            '${selectedDetail.forkliftId}',
                            Theme.of(context).colorScheme,
                          ),
                          CommonUi().horizontalDivider(height: 6),
                          CommonUi().detailRow(
                            "Weight :",
                            'N/A',
                            Theme.of(context).colorScheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Stack(clipBehavior: Clip.none, children: children);
          },
        ),
      );
    });
  }

  /// Single tap handler for the entire layer.
  /// Finds the closest bin to the tap in screen space and selects it.
  void _handleTap(Offset localPos) {
    const hitRadiusPx = 20.0; // tap radius around icon center

    BinModel? hitBin;
    double bestDist2 = hitRadiusPx * hitRadiusPx;

    for (final b in widget.bins) {
      final x = b.x;
      final y = b.y;
      if (x == 0 && y == 0) continue;

      final screenPos = _toScreen(x, y);

      final dx = screenPos.dx - localPos.dx;
      final dy = screenPos.dy - localPos.dy;
      final d2 = dx * dx + dy * dy;

      if (d2 <= bestDist2) {
        bestDist2 = d2;
        hitBin = b;
      }
    }

    if (hitBin == null) {
      // Tap missed all bins → clear selection
      binController.selectedBin.value = null;
      binController.selectedBinForDetail.value = null;
    } else {
      // Tap hit a bin → select it
      binController.selectedBin.value = hitBin;
      binController.selectedBinForDetail.value = hitBin;
    }

    setState(() {});
  }
}
