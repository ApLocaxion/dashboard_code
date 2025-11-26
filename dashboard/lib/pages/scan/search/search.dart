import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/pages/map_view/search/searchMapView.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  final binController = Get.find<BinController>(tag: 'binController');
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );
  final mapController = Get.find<MapController>(tag: 'mapController');

  final mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // final filteredLOO

    return Scaffold(
      body: Column(
        children: [
          CommonUi().globalHeader(
            wifiOnline: true,
            context: context,
            deviceId: homePageController.deviceId.value,
            rtlsActive: true,
            battery: 82,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: colors.onSurface,
                        iconSize: 32,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: 'Search by Bin ID or Alloy Grade...',
                            // prefixText: "Bin",
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colors.tertiary,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colors.tertiary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (v) => setState(() => query = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final filtered = binController.allBin
                              .where(
                                (b) => query.isEmpty || b.binId.contains(query),
                              )
                              .toList();
                          final _ = binController.selectedBin.value;
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                BinModel bin = filtered[index];
                                final isSelected =
                                    binController.selectedBin.value?.binId ==
                                    bin.binId;
                                return GestureDetector(
                                  onTap: () {
                                    final box =
                                        mapKey.currentContext
                                                ?.findRenderObject()
                                            as RenderBox?;
                                    if (box == null) return;
                                    final size = box.size;
                                    final center = size.center(Offset.zero);
                                    mapController.zoom.value = 15;

                                    // reuse the same transform as SearchMapView/MarkerLayer
                                    Offset toScreen(double xm, double ym) {
                                      const origin =
                                          -20.0; // MapConfig.marginMetersb
                                      final z = mapController.zoom.value;
                                      final xPx =
                                          (xm - origin) * z +
                                          mapController.panPx.value.dx;
                                      final yImg = (ym - origin) * z;
                                      final heightPx =
                                          (150 + 2 * 20) *
                                          z; // width/height + margins
                                      final yPx =
                                          (heightPx - yImg) +
                                          mapController.panPx.value.dy;
                                      return Offset(xPx, yPx);
                                    }

                                    final markerPx = toScreen(bin.x, bin.y);
                                    mapController.panPx.value +=
                                        center - markerPx;

                                    binController.selectedBin.value = bin;
                                    binController.selectedBinForDetail.value =
                                        null;
                                  },
                                  child: CommonUi().appCard(
                                    context: context,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                bin.binId,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                  color: isSelected
                                                      ? colors.primary
                                                      : colors.onSurfaceVariant,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${bin.alloy}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              bin.weightKg,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurfaceVariant,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "bin.weight",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: colors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        const SizedBox(width: 24),
                        // Right details + map
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  key: mapKey,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7F0),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: colors.tertiary),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          255,
                                          214,
                                          214,
                                          214,
                                        ),
                                        blurRadius: 12, // how soft
                                        spreadRadius: 2, // how wide
                                        offset: const Offset(
                                          0,
                                          4,
                                        ), // shadow position
                                      ),
                                    ],
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  child: SearchMapView(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              CommonUi().appCard(
                                padding: EdgeInsetsGeometry.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                context: context,
                                child: Row(
                                  children: [
                                    CommonUi().buildToggle(
                                      label: "BIN",
                                      value: mapController.showBin,
                                      colors: Theme.of(context).colorScheme,
                                    ),
                                    CommonUi().buildToggle(
                                      label: "ZONE",
                                      value: mapController.showZone,
                                      colors: Theme.of(context).colorScheme,
                                    ),
                                    CommonUi().buildToggle(
                                      label: "GRID",
                                      value: mapController.showGrid,
                                      colors: Theme.of(context).colorScheme,
                                    ),
                                    CommonUi().buildToggle(
                                      label: "MAP",
                                      value: mapController.showMap,
                                      colors: Theme.of(context).colorScheme,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
