import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/pages/table/dashBoard.dart';
import 'package:dashboard/pages/table/summaryCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableWid extends StatefulWidget {
  const TableWid({super.key});

  @override
  State<TableWid> createState() => _TableWidState();
}

class _TableWidState extends State<TableWid> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BinReportScreen());
  }
}

class BinReportScreen extends StatefulWidget {
  const BinReportScreen({super.key});

  @override
  State<BinReportScreen> createState() => _BinReportScreenState();
}

class _BinReportScreenState extends State<BinReportScreen> {
  bool _showKg = false;
  String _searchQuery = "";
  int _sortColumnIndex = 0;
  bool _isAscending = true;
  List<String> _activeFilters = [];

  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );
  final binController = Get.find<BinController>(tag: 'binController');

  final List<String> _filterOptions = [
    '> 24h Dwell',
    'Heavy (>2k lbs)',
    'Empty',
  ];

  String _textOrNA(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : 'N/A';
  }

  int _intOrZero(int? value) => value ?? 0;

  int _lbsToKg(int weightLbs) => (weightLbs * 0.453592).round();

  String _formatWeight(int weightLbs) {
    final safeWeight = _intOrZero(weightLbs);
    return _showKg ? '${_lbsToKg(safeWeight)} kg' : '$safeWeight lbs';
  }

  int _safeDwellMinutes(String? dwellTime) {
    if (dwellTime == null || dwellTime.isEmpty) return 0;
    int mins = 0;
    for (final part in dwellTime.split(' ')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.endsWith('h')) {
        final hours =
            int.tryParse(trimmed.substring(0, trimmed.length - 1)) ?? 0;
        mins += hours * 60;
      } else if (trimmed.endsWith('m')) {
        mins += int.tryParse(trimmed.substring(0, trimmed.length - 1)) ?? 0;
      }
    }
    return mins;
  }

  double _safeFillPercentage(int weightLbs, int capacityLbs) {
    final safeCapacity = capacityLbs <= 0 ? 1 : capacityLbs;
    final pct = weightLbs / safeCapacity;
    if (pct.isNaN || pct.isInfinite) return 0.0;
    return pct.clamp(0.0, 1.0);
  }

  // Filter and Sort bins
  List<BinModel> get _filteredBins {
    List<BinModel> list;
    if (_searchQuery.isEmpty && _activeFilters.isEmpty) {
      list = List.from(binController.allBin);
    } else {
      list = binController.allBin.where((bin) {
        final id = _textOrNA(bin.binId).toLowerCase();
        final alloy = _textOrNA(bin.alloy).toLowerCase();
        final zone = _textOrNA(bin.zoneCode).toLowerCase();
        final weightLbs = _intOrZero(bin.weightLbs);
        final dwellMinutes = _safeDwellMinutes(bin.dwellTime);
        final query = _searchQuery.toLowerCase();

        bool matchesSearch =
            id.contains(query) || alloy.contains(query) || zone.contains(query);

        bool matchesFilters = true;
        if (_activeFilters.contains('> 24h Dwell')) {
          matchesFilters = matchesFilters && dwellMinutes > 24 * 60;
        }
        if (_activeFilters.contains('Heavy (>2k lbs)')) {
          matchesFilters = matchesFilters && weightLbs > 2000;
        }
        if (_activeFilters.contains('Empty')) {
          matchesFilters = matchesFilters && weightLbs == 0;
        }

        return matchesSearch && matchesFilters;
      }).toList();
    }

    // Sorting Logic
    list.sort((a, b) {
      int compareResult;
      switch (_sortColumnIndex) {
        case 0: // Bin ID
          compareResult = _textOrNA(a.binId).compareTo(_textOrNA(b.binId));
          break;
        case 1: // Alloy
          compareResult = _textOrNA(a.alloy).compareTo(_textOrNA(b.alloy));
          break;
        case 2: // Weight
          compareResult = _intOrZero(
            a.weightLbs,
          ).compareTo(_intOrZero(b.weightLbs));
          break;
        case 4: // Dwell Time
          compareResult = _safeDwellMinutes(
            a.dwellTime,
          ).compareTo(_safeDwellMinutes(b.dwellTime));
          break;
        default:
          compareResult = 0;
      }
      return _isAscending ? compareResult : -compareResult;
    });

    return list;
  }

  void _onSort(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      setState(() {
        _isAscending = !_isAscending;
      });
    } else {
      setState(() {
        _sortColumnIndex = columnIndex;
        _isAscending = true;
      });
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
  }

  void _showInspector(BinModel bin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bin Inspector: ${_textOrNA(bin.binId)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _InspectorDetail('Alloy', _textOrNA(bin.alloy)),
                const SizedBox(width: 32),
                _InspectorDetail(
                  'Current Weight',
                  '${_intOrZero(bin.weightLbs)} lbs',
                ),
                const SizedBox(width: 32),
                _InspectorDetail(
                  'Fill Level',
                  '${(_safeFillPercentage(_intOrZero(bin.weightLbs), _intOrZero(bin.capacityLbs)) * 100).toInt()}%',
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('RECENT HISTORY', style: AppStyles.metricLabel),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _HistoryItem(
                    time: '10:30 AM',
                    event: 'Moved to ${_textOrNA(bin.zoneCode)}',
                    user: 'Forklift 03',
                  ),
                  _HistoryItem(
                    time: '08:15 AM',
                    event: 'Created at ${_textOrNA(bin.origin)}',
                    user: 'System',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Obx(() {
      //
      final _ = binController.allBin;
      return Column(
        children: [
          CommonUi().globalHeader(
            wifiOnline: true,
            deviceId: homePageController.deviceId.value,
            context: context,
            rtlsActive: true,
            battery: 82,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ///
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(size.width / 50),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.tertiary),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width / 42),
                      Text(
                        'Bin Inventory Report',
                        style: TextStyle(
                          fontSize: size.width / 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      // Export Button (New)
                      IconButton(
                        onPressed: () {
                          /* Export Logic */
                        },
                        icon: Icon(
                          Icons.share,
                          color: colors.primary,
                          size: size.width / 42,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search Bar
                      Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: size.width / 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.tertiary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: colors.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search Report...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Color(0xFFC7C7CC),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Unit Toggle Button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _UnitToggleOption(
                              label: 'LBS',
                              isSelected: !_showKg,
                              onTap: () => setState(() => _showKg = false),
                            ),
                            _UnitToggleOption(
                              label: 'KG',
                              isSelected: _showKg,
                              onTap: () => setState(() => _showKg = true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips Row (New)
                  Row(
                    children: [
                      Text(
                        'Quick Filters:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurfaceVariant,
                          fontSize: size.width / 82,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        children: _filterOptions.map((filter) {
                          final isSelected = _activeFilters.contains(filter);
                          return FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) => _toggleFilter(filter),
                            backgroundColor: Colors.white,
                            selectedColor: colors.primary.withValues(
                              alpha: 0.2,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colors.primary
                                  : colors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width / 82,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? colors.primary
                                    : colors.tertiary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Summary Metrics Row
                  Row(
                    children: [
                      SummaryCard(
                        label: 'TOTAL BINS',
                        value: '${_filteredBins.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(width: 16),
                      SummaryCard(
                        label: 'TOTAL WEIGHT',
                        value: _calculateTotalWeight(),
                        icon: Icons.scale_outlined,
                      ),
                      const SizedBox(width: 16),
                      SummaryCard(
                        label: 'AVG DWELL TIME',
                        value: '3h 12m',
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Report Table Container
                  Expanded(
                    child: DashboardCard(
                      padding: const EdgeInsets.all(0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          children: [
                            // Table Header with Sort
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 24,
                              ),
                              color: const Color(0xFFF9FAFB),
                              child: Row(
                                children: [
                                  _buildSortableHeader('BIN ID', 0, flex: 2),
                                  _buildSortableHeader(
                                    'ALLOY GRADE',
                                    1,
                                    flex: 3,
                                  ),
                                  _buildSortableHeader(
                                    'WEIGHT (${_showKg ? 'KG' : 'LBS'})',
                                    2,
                                    flex: 2,
                                  ),
                                  _buildHeaderCell(
                                    'LOCATION',
                                    flex: 3,
                                  ), // Not sortable for now
                                  _buildSortableHeader(
                                    'DWELL TIME',
                                    4,
                                    flex: 2,
                                  ),
                                  _buildHeaderCell(
                                    'ORIGIN',
                                    flex: 3,
                                  ), // Not sortable for now
                                ],
                              ),
                            ),
                            Divider(height: 1, color: colors.tertiary),

                            // Table Body (Scrollable List)
                            Expanded(
                              child: ListView.separated(
                                itemCount: _filteredBins.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: colors.tertiary),
                                itemBuilder: (context, index) {
                                  final bin = _filteredBins[index];
                                  final safeId = _textOrNA(bin.binId);
                                  final safeAlloy = _textOrNA(bin.alloy);
                                  final safeZone = _textOrNA(bin.zoneCode);
                                  final safeOrigin = _textOrNA(bin.origin);
                                  final safeDwellTime = _textOrNA(
                                    bin.dwellTime,
                                  );
                                  final weightLbs = _intOrZero(bin.weightLbs);
                                  final capacityLbs = _intOrZero(
                                    bin.capacityLbs,
                                  );
                                  final weightDisplay = _formatWeight(
                                    weightLbs,
                                  );
                                  final fillPercentage = _safeFillPercentage(
                                    weightLbs,
                                    capacityLbs,
                                  );
                                  final dwellMinutes = _safeDwellMinutes(
                                    bin.dwellTime,
                                  );
                                  final isLongDwell = dwellMinutes > 24 * 60;

                                  return InkWell(
                                    onTap: () => _showInspector(bin),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ), // Reduced vertical padding
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFFCFDFF),
                                      child: Row(
                                        children: [
                                          _buildDataCell(
                                            safeId,
                                            flex: 2,
                                            isBold: true,
                                          ),
                                          // Alloy Badge Logic
                                          Expanded(
                                            flex: 3,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: _AlloyBadge(
                                                alloy: safeAlloy,
                                              ),
                                            ),
                                          ),
                                          // Weight with Fill Indicator
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  weightDisplay,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                _FillIndicator(
                                                  percentage: fillPercentage,
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildDataCell(safeZone, flex: 3),
                                          _buildDataCell(
                                            safeDwellTime,
                                            flex: 2,
                                            color: isLongDwell
                                                ? colors.error
                                                : colors.onSurfaceVariant,
                                            isBold: isLongDwell,
                                          ),
                                          _buildDataCell(safeOrigin, flex: 3),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  String _calculateTotalWeight() {
    final totalLbs = _filteredBins.fold(
      0,
      (sum, bin) => sum + _intOrZero(bin.weightLbs),
    );
    return _formatWeight(totalLbs);
  }

  Widget _buildSortableHeader(String text, int index, {required int flex}) {
    final isSelected = _sortColumnIndex == index;

    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _onSort(index),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: size.width / 78,
                fontWeight: FontWeight.w900,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            if (isSelected)
              Icon(
                _isAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: colors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width / 78,
          fontWeight: FontWeight.w900,
          color: colors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required int flex,
    bool isBold = false,
    Color? color,
    bool? isBoldOverride,
  }) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width / 70,
          fontWeight: (isBoldOverride ?? isBold)
              ? FontWeight.w800
              : FontWeight.w600,
          color: color ?? colors.onSurface,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _InspectorDetail extends StatelessWidget {
  final String label;
  final String value;

  const _InspectorDetail(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.metricLabel),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String time;
  final String event;
  final String user;

  const _HistoryItem({
    required this.time,
    required this.event,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              event,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            user,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FillIndicator extends StatelessWidget {
  final double percentage;

  const _FillIndicator({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Color color;
    if (percentage > 0.95) {
      color = colors.error;
    } else if (percentage > 0.80) {
      color = colors.scrim;
    } else {
      color = colors.surfaceTint;
    }

    return Container(
      height: 4,
      width: 60,
      decoration: BoxDecoration(
        color: colors.tertiary,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.centerLeft,
      child: Container(
        width: 60 * percentage,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// Helper Widget for Alloy Badges
class _AlloyBadge extends StatelessWidget {
  final String alloy;

  const _AlloyBadge({required this.alloy});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (alloy.startsWith('3')) {
      // 3xxx Series
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue[800]!;
    } else if (alloy.startsWith('5')) {
      // 5xxx Series
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green[800]!;
    } else if (alloy.startsWith('6')) {
      // 6xxx Series
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange[800]!;
    } else if (alloy.startsWith('7')) {
      // 7xxx Series
      bgColor = Colors.purple.withOpacity(0.1);
      textColor = Colors.purple[800]!;
    } else {
      bgColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        alloy,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _UnitToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.black : const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }
}
