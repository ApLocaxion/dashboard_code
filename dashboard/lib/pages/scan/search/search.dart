import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
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
  BinModel? selected;

  final binController = Get.find<BinController>(tag: 'binController');
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = binController.allBin.where((b) {
      if (query.isEmpty) return true;
      // final q = query.toUpperCase();
      return b.binId.contains(query);

      /// with alloys
      ///  || b.alloy.toUpperCase().contains(q);
    }).toList();

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
                          ///
                          ///Get
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
                      children: [
                        // Left list
                        SizedBox(
                          width: 260,
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final bin = filtered[index];
                              final isSelected = selected?.binId == bin.binId;
                              return GestureDetector(
                                onTap: () => setState(() => selected = bin),
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
                                              "bin.alloy",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: colors.onSurfaceVariant,
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
                                            'WEIGHT',
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
                        ),
                        const SizedBox(width: 24),
                        // Right details + map
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7F0),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: colors.tertiary),
                            ),
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: selected == null
                                ? SearchMapView()
                                : Column(
                                    children: [
                                      CommonUi().appCard(
                                        context: context,
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selected!.binId,
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w900,
                                                color: colors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _detailRow(
                                              'Grade',
                                              "selected!.alloy",
                                              colors,
                                            ),
                                            const Divider(),
                                            _detailRow(
                                              'Weight',
                                              selected!.weight.toString(),
                                              colors,
                                            ),
                                            const Divider(),
                                            _detailRow(
                                              'Location',
                                              selected!.zoneCode == null
                                                  ? " zoneCore"
                                                  : "NA",
                                              colors,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: CommonUi().appCard(
                                          context: context,
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.public_rounded,
                                                size: 60,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'No Zone Data Available',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colors.primary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                          onPressed: () {
                                            ///
                                            selected;
                                          },
                                          child: const Text(
                                            'LOAD THIS BIN',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget _detailRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
