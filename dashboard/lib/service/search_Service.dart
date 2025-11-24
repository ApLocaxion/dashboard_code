import 'dart:convert';

import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/search_controller.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:get/get.dart';

class SearchService {
  //
  final searchControllerq = Get.find<SearchControllerQuery>(
    tag: 'searchController',
  );
  final binController = Get.find<BinController>(tag: 'binController');

  getSearchResult() {
    searchControllerq.results.clear();

    searchControllerq.results.value =
        findBinsFromText(searchControllerq.searchQuery.value.text.trim()) ?? [];
  }

  List<BinModel>? findBinsFromText(String input) {
    final normalizedInput = input.toLowerCase().trim();
    if (normalizedInput.isEmpty) return [];

    final matches = (binController.allBin as List<BinModel>).where((b) {
      final binId = b.binId.toLowerCase();

      // Remove hyphens/spaces to make flexible matching
      final normalizedBinId = binId.replaceAll(RegExp(r'[-\s]'), '');
      final normalizedInputClean = normalizedInput.replaceAll(
        RegExp(r'[-\s]'),
        '',
      );

      // Match if either contains the other (partial match in both directions)
      return normalizedBinId.contains(normalizedInputClean) ||
          normalizedInputClean.contains(normalizedBinId);
    }).toList();

    // Optional: sort results so closest matches (shorter diff) come first
    matches.sort((a, b) => a.binId.compareTo(b.binId));

    return matches;
  }
}
