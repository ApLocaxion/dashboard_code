//ADVANCED DASHBOARD//
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScrapViewApp extends StatelessWidget {
  const ScrapViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrapView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: false,
      ),
      home: const ScrapViewDashboard(),
    );
  }
}

class ScrapViewDashboard extends StatelessWidget {
  const ScrapViewDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: const [
                  _PrimaryActionsRow(),
                  SizedBox(height: 16),
                  _KpiRow(),
                  SizedBox(height: 16),
                  _TopMainRow(), // Scrap capacity + Yard intelligence
                  SizedBox(height: 16),
                  AlloyMixCard(),
                  SizedBox(height: 16),
                  _FlowAndEmptyRow(),
                  SizedBox(height: 16),
                  SystemHealthCard(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   APP BAR                                  */
/* -------------------------------------------------------------------------- */

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          const Text(
            'LocaXion | ELVAL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Text(
            'ScrapView™',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _StatusPill(icon: Icons.power_settings_new, label: 'On-Line'),
          const SizedBox(width: 8),
          _StatusPill(icon: Icons.show_chart, label: 'RTLS Active'),
          const SizedBox(width: 8),
          _BatteryPill(),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryPill extends StatelessWidget {
  @override
  const _BatteryPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: const [
          Icon(Icons.battery_full, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '82% BATTERY',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              TOP PRIMARY ACTIONS                           */
/* -------------------------------------------------------------------------- */

class _PrimaryActionsRow extends StatelessWidget {
  const _PrimaryActionsRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live view of yard capacity, alloy distribution, empty-bin health and yard intelligence.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: _ActionButton(icon: Icons.search, label: 'Alloy Finder'),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _ActionButton(icon: Icons.map, label: 'Live Map'),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: Icons.local_shipping,
                label: 'Forklifts',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        // Hook for navigation later.
        debugPrint('$label tapped');
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   METRICS                                  */
/* -------------------------------------------------------------------------- */

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _KpiCard(
            title: 'TOTAL BINS IN YARD',
            value: '1,817 / 2,500',
            subtitle: 'In use vs total bins',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            title: 'BIN SLOT UTILIZATION',
            value: '81%',
            subtitle: '34 compartments × 3 levels × 22 slots',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            title: 'EMPTY BINS AVAILABLE',
            value: '683',
            subtitle: 'Enough for ~3.2 hours at current rate',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            title: 'TOTAL SCRAP WEIGHT',
            value: '502 t',
            subtitle: '≈ 1,107,000 lb on the floor',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.7,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              MAIN ROW (TOP HALF)                           */
/* -------------------------------------------------------------------------- */

class _TopMainRow extends StatelessWidget {
  const _TopMainRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 3, child: ScrapCapacityCard()),
        SizedBox(width: 16),
        Expanded(flex: 2, child: YardIntelligenceCard()),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                           SCRAP CAPACITY & UTILIZATION                     */
/* -------------------------------------------------------------------------- */

class ScrapCapacityCard extends StatelessWidget {
  const ScrapCapacityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _CompRowData(
        id: 'COMP-01',
        label: '44 of 66 slots in use · 67% full',
        detail: '22 empty · 33% free · Top alloy Al 5052',
        tons: '71.2 t',
        pounds: '156,925 lb',
        fill: 0.67,
        highRisk: false,
      ),
      _CompRowData(
        id: 'COMP-03',
        label: '39 of 66 slots in use · 59% full',
        detail: '27 empty · 41% free · Top alloy Al 3105',
        tons: '62.0 t',
        pounds: '136,648 lb',
        fill: 0.59,
        highRisk: false,
      ),
      _CompRowData(
        id: 'COMP-08',
        label: '48 of 66 slots in use · 73% full',
        detail: '18 empty · 27% free · Top alloy Al 3003',
        tons: '76.8 t',
        pounds: '169,267 lb',
        fill: 0.73,
        highRisk: false,
      ),
      _CompRowData(
        id: 'COMP-12',
        label: '64 of 66 slots in use · 97% full',
        detail: '2 empty · 3% free · Top alloy Al 5182',
        tons: '118.4 t',
        pounds: '260,954 lb',
        fill: 0.97,
        highRisk: true,
      ),
    ];

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Scrap Capacity & Utilization',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '34 compartments · 3 levels · 22 slots each. Compartment fill, tonnage and free slots.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 18),
          Column(children: rows.map((r) => _CompUtilRow(data: r)).toList()),
          const SizedBox(height: 12),
          const Text(
            'High-risk capacity · consider re-slotting within the next 2 hours.',
            style: TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }
}

class _CompRowData {
  _CompRowData({
    required this.id,
    required this.label,
    required this.detail,
    required this.tons,
    required this.pounds,
    required this.fill,
    required this.highRisk,
  });

  final String id;
  final String label;
  final String detail;
  final String tons;
  final String pounds;
  final double fill;
  final bool highRisk;
}

class _CompUtilRow extends StatelessWidget {
  const _CompUtilRow({required this.data});

  final _CompRowData data;

  @override
  Widget build(BuildContext context) {
    final barColor = data.highRisk
        ? const Color(0xFFEF4444)
        : const Color(0xFF2563EB);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              data.id,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fullWidth = constraints.maxWidth;
                    final barWidth = fullWidth * data.fill.clamp(0.0, 1.0);
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          width: fullWidth,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  data.detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.tons,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                data.pounds,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               YARD INTELLIGENCE                            */
/* -------------------------------------------------------------------------- */

class YardIntelligenceCard extends StatefulWidget {
  const YardIntelligenceCard({super.key});

  @override
  State<YardIntelligenceCard> createState() => _YardIntelligenceCardState();
}

class _YardIntelligenceCardState extends State<YardIntelligenceCard> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Insight(
        title: 'Overflow risk in COMP-12',
        metric: '94% full · risk in ~1.5 h',
        color: const Color(0xFFDC2626),
        badge: 'Action',
        description:
            '5182-heavy compartment. Model predicts overflow in ≈1.5 h at current inflow. Move 6 full bins to YARD-1.',
      ),
      _Insight(
        title: 'Empty shortage at Slitter 12',
        metric: '< 1.2 h of empties staged',
        color: const Color(0xFFB45309),
        badge: 'Stage empties',
        description:
            'Only 3 empties nearby. Consumption ≈2.4 bins/h. Pre-stage 5 empties from COMP-03.',
      ),
      _Insight(
        title: 'Scrap anomaly at Tandem 2',
        metric: '+38% 5182 vs baseline',
        color: const Color(0xFF2563EB),
        badge: 'Blend risk',
        description:
            'Model flags unusual 5182 mix vs 7-day baseline for similar coils. Check mill schedule.',
      ),
      _Insight(
        title: 'Blend risk in COMP-19',
        metric: '3xx / 5xxx mix',
        color: const Color(0xFF7C3AED),
        badge: 'Investigate',
        description:
            'Composition drift above melt-plan tolerance. Consider re-slotting before weekend melt.',
      ),
    ];

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Yard Intelligence',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Model-driven insights for overflow, empties, anomalies and blend risk.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) {
                setState(() => _pageIndex = i);
              },
              itemBuilder: (context, index) {
                final insight = pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _InsightCard(insight: insight),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _pageIndex
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFD1D5DB),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Swipe horizontally for more insights →',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Insight {
  _Insight({
    required this.title,
    required this.metric,
    required this.color,
    required this.badge,
    required this.description,
  });

  final String title;
  final String metric;
  final Color color;
  final String badge;
  final String description;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: insight.color.withOpacity(0.5)),
                ),
                child: Text(
                  insight.badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: insight.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight.metric,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: insight.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              IMPROVED ALLOY MIX                            */
/* -------------------------------------------------------------------------- */

class AlloyShare {
  final String name;
  final double weightTons;
  final double sharePercent;
  final int bins;
  final int purityScore;
  final String topCompartments;
  final String topSources;
  final Color color;

  const AlloyShare({
    required this.name,
    required this.weightTons,
    required this.sharePercent,
    required this.bins,
    required this.purityScore,
    required this.topCompartments,
    required this.topSources,
    required this.color,
  });
}

class AlloyMixCard extends StatefulWidget {
  const AlloyMixCard({super.key});

  @override
  State<AlloyMixCard> createState() => _AlloyMixCardState();
}

class _AlloyMixCardState extends State<AlloyMixCard> {
  late List<AlloyShare> alloys;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    alloys = const [
      AlloyShare(
        name: 'Alloy 5182',
        weightTons: 142.5,
        sharePercent: 34,
        bins: 412,
        purityScore: 92,
        topCompartments: 'COMP-12, COMP-19',
        topSources: 'Slitters 15–18, Tandem 2',
        color: Color(0xFF2563EB),
      ),
      AlloyShare(
        name: 'Alloy 5052',
        weightTons: 96.2,
        sharePercent: 23,
        bins: 281,
        purityScore: 89,
        topCompartments: 'COMP-01, COMP-08',
        topSources: 'Slitters 5–12',
        color: Color(0xFF10B981),
      ),
      AlloyShare(
        name: 'Alloy 3003',
        weightTons: 74.0,
        sharePercent: 18,
        bins: 196,
        purityScore: 81,
        topCompartments: 'COMP-03, COMP-21',
        topSources: 'Blanking, Scalper',
        color: Color(0xFFF97316),
      ),
      AlloyShare(
        name: 'Alloy 3105',
        weightTons: 50.8,
        sharePercent: 12,
        bins: 143,
        purityScore: 79,
        topCompartments: 'COMP-09, COMP-27',
        topSources: 'Edge trim, Rewinder',
        color: Color(0xFF6366F1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final alloy = alloys[selectedIndex];

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Alloy Mix & Purity',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Tap a slice or alloy to inspect tonnage, bins and purity.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // Donut + legend
              Expanded(
                flex: 7,
                child: Row(
                  children: [
                    GestureDetector(
                      onTapUp: (details) {
                        final hit = _hitTestAlloySlice(
                          details.localPosition,
                          const Size(160, 160),
                          alloys,
                        );
                        if (hit != -1 && hit != selectedIndex) {
                          setState(() => selectedIndex = hit);
                        }
                      },
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _AlloyPiePainter(
                            alloys: alloys,
                            selectedIndex: selectedIndex,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${alloy.sharePercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'of yard',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: alloys.asMap().entries.map((entry) {
                          final index = entry.key;
                          final a = entry.value;
                          final isSelected = index == selectedIndex;
                          return InkWell(
                            onTap: () {
                              setState(() => selectedIndex = index);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? a.color.withOpacity(0.06)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: a.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      a.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${a.sharePercent.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Purity ${a.purityScore}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Detail panel
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: alloy.color.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: alloy.color.withOpacity(0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alloy.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _metricChip(
                            label: 'Tonnage',
                            value: '${alloy.weightTons.toStringAsFixed(1)} t',
                          ),
                          _metricChip(
                            label: 'Bins',
                            value: alloy.bins.toString(),
                          ),
                          _metricChip(
                            label: 'Purity',
                            value: '${alloy.purityScore} / 100',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Top compartments:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              alloy.topCompartments,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            'Top sources:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              alloy.topSources,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.5,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AlloyPiePainter extends CustomPainter {
  _AlloyPiePainter({required this.alloys, required this.selectedIndex});

  final List<AlloyShare> alloys;
  final int selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    canvas.drawCircle(center, radius, bgPaint);

    final totalPercent = alloys.fold<double>(
      0,
      (sum, a) => sum + a.sharePercent,
    );

    double startAngle = -math.pi / 2;

    for (int i = 0; i < alloys.length; i++) {
      final alloy = alloys[i];
      final sweep = (alloy.sharePercent / totalPercent) * 2 * math.pi;

      final paint = Paint()
        ..color = alloy.color.withOpacity(i == selectedIndex ? 1 : 0.45)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = i == selectedIndex ? 26 : 22;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AlloyPiePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.alloys != alloys;
  }
}

int _hitTestAlloySlice(Offset localPos, Size size, List<AlloyShare> alloys) {
  final center = size.center(Offset.zero);
  final dx = localPos.dx - center.dx;
  final dy = localPos.dy - center.dy;
  final distance = math.sqrt(dx * dx + dy * dy);

  final outerRadius = size.shortestSide / 2;
  final innerRadius = outerRadius - 30;

  if (distance < innerRadius || distance > outerRadius + 8) {
    return -1;
  }

  final angle = math.atan2(dy, dx);
  double normalized = angle + math.pi / 2;
  if (normalized < 0) normalized += 2 * math.pi;

  final totalPercent = alloys.fold<double>(0, (sum, a) => sum + a.sharePercent);
  double startAngle = 0;

  for (int i = 0; i < alloys.length; i++) {
    final alloy = alloys[i];
    final sweep = (alloy.sharePercent / totalPercent) * 2 * math.pi;
    if (normalized >= startAngle && normalized <= startAngle + sweep) {
      return i;
    }
    startAngle += sweep;
  }
  return -1;
}

/* -------------------------------------------------------------------------- */
/*                         FLOW & EMPTY HEALTH ROW                            */
/* -------------------------------------------------------------------------- */

class _FlowAndEmptyRow extends StatelessWidget {
  const _FlowAndEmptyRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: FlowTurnoverCard()),
        SizedBox(width: 16),
        Expanded(child: EmptyHealthByProcessCard()),
      ],
    );
  }
}

class FlowTurnoverCard extends StatelessWidget {
  const FlowTurnoverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Flow & Turnover',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'How quickly scrap is moving from lines to yard.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _FlowMetric(label: 'Bins moved / h', value: '146'),
              _FlowMetric(label: 'Avg cycle time', value: '2.9 min'),
              _FlowMetric(label: 'Bin turns / week', value: '4.2×'),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Top lanes (last 60 min)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _laneRow('Slitters → Scale', '58 bins · 2.4 min / bin'),
          _laneRow('Tandem → YARD-1', '31 bins · 3.1 min / bin'),
          _laneRow('Blanking → COMP-03', '22 bins · 2.7 min / bin'),
        ],
      ),
    );
  }

  static Widget _laneRow(String lane, String stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.trending_up, size: 14, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Expanded(child: Text(lane, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Text(
            stat,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _FlowMetric extends StatelessWidget {
  const _FlowMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

/* ----------------------------- EMPTY HEALTH CARD -------------------------- */

class EmptyHealthByProcessCard extends StatelessWidget {
  const EmptyHealthByProcessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final processes = [
      _ProcessHealth(
        name: 'Slitters 1–8',
        hoursToShortage: 3.8,
        stagedEmpties: 24,
        consumption: 6.2,
        state: _HealthState.ok,
      ),
      _ProcessHealth(
        name: 'Slitters 9–18',
        hoursToShortage: 1.3,
        stagedEmpties: 9,
        consumption: 7.1,
        state: _HealthState.watch,
      ),
      _ProcessHealth(
        name: 'Tandem mills',
        hoursToShortage: 4.5,
        stagedEmpties: 15,
        consumption: 3.2,
        state: _HealthState.ok,
      ),
      _ProcessHealth(
        name: 'Blanking & Scalper',
        hoursToShortage: 2.1,
        stagedEmpties: 12,
        consumption: 4.4,
        state: _HealthState.ok,
      ),
    ];

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Empty Health by Process',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Projected hours until empty-bin shortage by scrap origin.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            physics: const NeverScrollableScrollPhysics(),
            children: processes
                .map((p) => _ProcessHealthTile(data: p))
                .toList(),
          ),
        ],
      ),
    );
  }
}

enum _HealthState { ok, watch, alert }

class _ProcessHealth {
  _ProcessHealth({
    required this.name,
    required this.hoursToShortage,
    required this.stagedEmpties,
    required this.consumption,
    required this.state,
  });

  final String name;
  final double hoursToShortage;
  final int stagedEmpties;
  final double consumption;
  final _HealthState state;
}

class _ProcessHealthTile extends StatelessWidget {
  const _ProcessHealthTile({required this.data});

  final _ProcessHealth data;

  @override
  Widget build(BuildContext context) {
    Color accent;
    String label;
    Color bg;

    switch (data.state) {
      case _HealthState.ok:
        accent = const Color(0xFF16A34A);
        label = 'OK';
        bg = const Color(0xFFE5F8F0);
        break;
      case _HealthState.watch:
        accent = const Color(0xFFF97316);
        label = 'Watch';
        bg = const Color(0xFFFFF7ED);
        break;
      case _HealthState.alert:
        accent = const Color(0xFFDC2626);
        label = 'Alert';
        bg = const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.hoursToShortage.toStringAsFixed(1)} h to shortage',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.stagedEmpties} empties staged · '
            '${data.consumption.toStringAsFixed(1)} bins/h consumption',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                             SYSTEM HEALTH (RTLS)                            */
/* -------------------------------------------------------------------------- */

class SystemHealthCard extends StatelessWidget {
  const SystemHealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final attentionForklifts = [
      _ForkliftHealth(
        id: 'FK-03',
        rtlsStatus: 'RTLS lagging',
        wifiStatus: 'Wi-Fi weak',
        lastSeen: '32 s ago',
      ),
      _ForkliftHealth(
        id: 'FK-07',
        rtlsStatus: 'No RTLS data',
        wifiStatus: 'Wi-Fi dropouts',
        lastSeen: '3.4 min ago',
      ),
    ];

    final badQrCodes = [
      _QrIssue(
        code: 'QR-YARD-128',
        location: 'COMP-12 / L2 / slot 18',
        failedReads: 9,
        lastSeen: '09:14',
      ),
      _QrIssue(
        code: 'QR-TDM-042',
        location: 'Tandem exit lane 2',
        failedReads: 5,
        lastSeen: '08:51',
      ),
    ];

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'System Health',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Forklift SLAM RTLS and Wi-Fi connectivity.',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _topHealthMetric(
                label: 'Forklifts online',
                value: '26 / 28',
                color: const Color(0xFF16A34A),
              ),
              _topHealthMetric(
                label: 'RTLS uptime',
                value: '99.2 %',
                color: const Color(0xFF2563EB),
              ),
              _topHealthMetric(
                label: 'RTLS P95 latency',
                value: '120 ms',
                color: const Color(0xFF7C3AED),
              ),
              _topHealthMetric(
                label: 'Wi-Fi at risk',
                value: '2 zones',
                color: const Color(0xFFF97316),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Forklifts needing attention
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forklifts needing attention',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (attentionForklifts.isEmpty)
                      const Text(
                        'All forklifts healthy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      )
                    else
                      ...attentionForklifts.map(_forkliftRow),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // QR codes with issues
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QR codes with scan issues',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (badQrCodes.isEmpty)
                      const Text(
                        'No repeated failures',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      )
                    else
                      ...badQrCodes.map(_qrRow),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topHealthMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _forkliftRow(_ForkliftHealth f) {
    final rtlsColor = f.rtlsStatus.contains('No')
        ? const Color(0xFFDC2626)
        : const Color(0xFFF97316);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              f.id,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          _statusDot(rtlsColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(f.rtlsStatus, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          _statusDot(const Color(0xFFF97316)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(f.wifiStatus, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text(
            f.lastSeen,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _qrRow(_QrIssue q) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              q.code,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              q.location,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${q.failedReads} fails',
              style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ForkliftHealth {
  final String id;
  final String rtlsStatus;
  final String wifiStatus;
  final String lastSeen;

  _ForkliftHealth({
    required this.id,
    required this.rtlsStatus,
    required this.wifiStatus,
    required this.lastSeen,
  });
}

class _QrIssue {
  final String code;
  final String location;
  final int failedReads;
  final String lastSeen;

  _QrIssue({
    required this.code,
    required this.location,
    required this.failedReads,
    required this.lastSeen,
  });
}

/* -------------------------------------------------------------------------- */
/*                               SHARED CARD SHELL                            */
/* -------------------------------------------------------------------------- */

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
