import 'package:dashboard/controller/search_controller.dart';
import 'package:dashboard/service/search_Service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSearchPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 8),
                color: Colors.black26,
              ),
            ],
          ),
          // Let the bottom sheet grow/shrink with a drag handle behavior.
          child: const _DraggableSearchSheet(),
        ),
      );
    },
  );
}

class _DraggableSearchSheet extends StatelessWidget {
  const _DraggableSearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // Start at ~70% of screen height; user can drag up to 95%.
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return _SearchPanelBody(
          // Pass the scrollController so the whole sheet scrolls as one.
          parentScrollController: scrollController,
        );
      },
    );
  }
}

class _SearchPanelBody extends StatefulWidget {
  const _SearchPanelBody({super.key, this.parentScrollController});
  final ScrollController? parentScrollController;

  @override
  State<_SearchPanelBody> createState() => _SearchPanelBodyState();
}

class _SearchPanelBodyState extends State<_SearchPanelBody> {
  final searchControllerq = Get.find<SearchControllerQuery>(
    tag: 'searchController',
  );

  @override
  Widget build(BuildContext context) {
    // Keep reactive to results
    return Obx(() {
      // Build as a CustomScrollView so the sheet scrolls fluidly.
      return CustomScrollView(
        controller: widget.parentScrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: searchControllerq.searchQuery.value,
                onChanged: (v) {
                  SearchService().getSearchResult();
                },
                decoration: InputDecoration(
                  hintText: 'Search boxes…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.keyboard),
                    onPressed: () {}, // custom action
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${searchControllerq.results.length} boxes found',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),

          // Grid with fixed 3 columns as requested.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // keep at 3
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // Make tiles a bit taller (lower ratio => more height)
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _BinCard(index: i),
                childCount: searchControllerq.results.length,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _BinCard extends StatelessWidget {
  final int index;
  const _BinCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final searchControllerq = Get.find<SearchControllerQuery>(
      tag: 'searchController',
    );
    final item = searchControllerq.results[index];

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Text(
              item.binId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Body grows/shrinks to avoid overflow
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 215, 215, 215),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Spread items evenly to use vertical space without overflow
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoLine(label: 'Grades', value: 'NA'),
                    _InfoLine(label: 'Weight', value: 'NA'),
                    _InfoLine(
                      label: 'Location',
                      value: (item.zoneCode == null)
                          ? 'NA'
                          : "${item.zoneCode}",
                    ),
                    _InfoLine(label: 'Modified', value: '${item.timeStamp}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
