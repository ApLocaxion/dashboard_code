import 'package:dashboard/common/common_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ForkliftApp());
}

/// COLORS & THEME HELPERS
class AppColors {
  static const Color blue = Color(0xFF007AFF);
  static const Color blueHeader = Color(0xFF0A74FF);
  static const Color pageBackground = Color(0xFFF2F2F7);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFD1D5DB);
}

class BinInfo {
  final String id;
  final String alloy;
  final String weight;
  final String zone;

  const BinInfo({
    required this.id,
    required this.alloy,
    required this.weight,
    required this.zone,
  });
}

// Mock data (like the React version)
final List<BinInfo> mockBins = List.generate(15, (i) {
  const alloys = ['303', '56', '504', '52', '403', '542', '342'];
  final alloyCode = alloys[i % alloys.length];
  return BinInfo(
    id: 'BIN-${400 + i}',
    alloy: 'Alloy $alloyCode',
    weight: 'N/A',
    zone: 'N/A',
  );
});

enum View { scan, confirm, loaded, search, options }

class ForkliftApp extends StatelessWidget {
  const ForkliftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocaXion Forklift UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'SF Pro Text',
        scaffoldBackgroundColor: AppColors.pageBackground,
      ),
      home: const ForkliftShell(),
    );
  }
}

class ForkliftShell extends StatefulWidget {
  const ForkliftShell({super.key});

  @override
  State<ForkliftShell> createState() => _ForkliftShellState();
}

class _ForkliftShellState extends State<ForkliftShell> {
  View _view = View.scan;
  BinInfo? _activeBin;

  // “System status” (mock)
  bool wifiOnline = true;
  bool rtlsActive = true;
  double battery = 0.82;
  String currentZone = 'A-12';
  String speed = 'N/A';
  String shiftTime = 'N/A';

  void _goTo(View view) {
    setState(() => _view = view);
  }

  void _onScan(BinInfo bin) {
    setState(() {
      _activeBin = bin;
      _view = View.confirm;
    });
  }

  void _confirmLoad() {
    setState(() => _view = View.loaded);
  }

  void _unload() {
    setState(() {
      _activeBin = null;
      _view = View.scan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.blue, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: Scaffold(
              backgroundColor: AppColors.pageBackground,
              body: Column(
                children: [
                  GlobalHeader(
                    wifiOnline: wifiOnline,
                    rtlsActive: rtlsActive,
                    battery: battery,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: _buildBody(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_view) {
      case View.scan:
        return ScanScreen(
          currentZone: currentZone,
          speed: speed,
          shiftTime: shiftTime,
          onScan: _onScan,
          onNavigate: _goTo,
        );
      case View.confirm:
        if (_activeBin == null) return const SizedBox();
        return ConfirmScreen(
          currentZone: currentZone,
          bin: _activeBin!,
          onConfirm: _confirmLoad,
          onCancel: () => _goTo(View.scan),
        );
      case View.loaded:
        if (_activeBin == null) return const SizedBox();
        return LoadedScreen(
          currentZone: currentZone,
          bin: _activeBin!,
          onUnload: _unload,
        );
      case View.search:
        return SearchScreen(
          bins: mockBins,
          onBack: () => _goTo(View.scan),
          onSelectBinForLoad: (bin) {
            _activeBin = bin;
            _goTo(View.confirm);
          },
        );
      case View.options:
        return OptionsScreen(onBack: () => _goTo(View.scan));
    }
  }
}

/// GLOBAL BLUE HEADER -------------------------------------------------------

class GlobalHeader extends StatelessWidget {
  final bool wifiOnline;
  final bool rtlsActive;
  final double battery;

  const GlobalHeader({
    super.key,
    required this.wifiOnline,
    required this.rtlsActive,
    required this.battery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blueHeader,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          // Left: Logo + Vehicle
          Expanded(
            child: Row(
              children: [
                const Text(
                  'LocaXion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 2,
                  height: 24,
                  color: Colors.white24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'VEHICLE ID',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB7CEFF),
                        letterSpacing: 1.8,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'FORKLIFT 03',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center spacer
          const Spacer(),

          // Right: Status pills + battery
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusPill(
                icon: Icons.wifi_rounded,
                label: wifiOnline ? 'On-Line' : 'Offline',
              ),
              const SizedBox(width: 8),
              _StatusPill(
                icon: Icons.signal_cellular_alt_rounded,
                label: rtlsActive ? 'RTLS Active' : 'RTLS Down',
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(battery * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'BATTERY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB7CEFF),
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.battery_full_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// COMMON WIDGETS -----------------------------------------------------------

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value${unit.isNotEmpty ? ' $unit' : ''}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PrimaryActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color == Colors.white ? AppColors.border : color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: color == Colors.white ? AppColors.blue : Colors.white,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color == Colors.white
                      ? AppColors.textPrimary
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ZoneBadge extends StatelessWidget {
  final String zone;

  const ZoneBadge({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return CommonUi().appCard(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'VEHICLE ZONE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.8,
                ),
              ),
              Text(
                zone,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

/// SCAN / READY TO LOAD SCREEN ---------------------------------------------

class ScanScreen extends StatefulWidget {
  final String currentZone;
  final String speed;
  final String shiftTime;
  final void Function(BinInfo bin) onScan;
  final void Function(View) onNavigate;

  const ScanScreen({
    super.key,
    required this.currentZone,
    required this.speed,
    required this.shiftTime,
    required this.onScan,
    required this.onNavigate,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool scannerReady = true;

  void _submitManual() {
    if (_controller.text.trim().isEmpty) return;
    final id = _controller.text.trim().toUpperCase();
    final bin = BinInfo(
      id: id,
      alloy: 'Unknown Alloy',
      weight: 'N/A',
      zone: 'N/A',
    );
    widget.onScan(bin);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOP ROW CARDS
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ready to Load',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 26,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'CURRENT OPERATOR',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Unassigned ',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '(Tap to login)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 32,
                        thickness: 2,
                        color: Color(0xFFE5E7EB),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CURRENT ZONE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.blue,
                                size: 26,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.currentZone,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: MetricCard(
                  icon: Icons.monitor_heart_rounded,
                  label: 'Speed',
                  value: widget.speed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: MetricCard(
                  icon: Icons.schedule_rounded,
                  label: 'Shift Time',
                  value: widget.shiftTime,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // BIG INPUT CARD
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                    onSubmitted: (_) => _submitManual(),
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'SCAN OR TYPE BIN ID',
                      hintStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary.withOpacity(0.4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.blue,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: scannerReady ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      scannerReady
                          ? 'SCANNER READY & ACTIVE'
                          : 'SCANNER DISCONNECTED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: scannerReady
                            ? AppColors.textSecondary
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // BOTTOM BUTTONS
        Row(
          children: [
            Expanded(
              child: PrimaryActionButton(
                icon: Icons.keyboard_rounded,
                label: 'MANUAL ENTRY',
                color: AppColors.blue,
                onTap: () {
                  // Focus TextField -> triggers OS keyboard on tablets
                  _focus.requestFocus();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryActionButton(
                icon: Icons.search_rounded,
                label: 'SEARCH BINS',
                color: Colors.white,
                onTap: () => widget.onNavigate(View.search),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// CONFIRM SCREEN -----------------------------------------------------------

class ConfirmScreen extends StatelessWidget {
  final BinInfo bin;
  final String currentZone;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmScreen({
    super.key,
    required this.bin,
    required this.currentZone,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'ARE YOU LOADING BIN?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bin.id,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 32),
            CommonUi().appCard(
              context: context,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                children: [
                  CommonUi().infoRow(
                    context: context,
                    label: 'ALLOY:',
                    value: 'bin.alloy',
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: CommonUi().primaryActionButton(
                    context: context,
                    icon: Icons.error_outline_rounded,
                    label: 'NO',
                    color: const Color(0xFFE53935),
                    onTap: onCancel,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: PrimaryActionButton(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'YES',
                    color: AppColors.blue,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(top: 12, right: 0, child: ZoneBadge(zone: currentZone)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// LOADED / CURRENT LOAD SCREEN --------------------------------------------

class LoadedScreen extends StatelessWidget {
  final BinInfo bin;
  final String currentZone;
  final VoidCallback onUnload;

  const LoadedScreen({
    super.key,
    required this.bin,
    required this.currentZone,
    required this.onUnload,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'CURRENT LOAD',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bin.id,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 24),
            CommonUi().appCard(
              context: context,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Column(
                      children: [
                        CommonUi().infoRow(
                          context: context,
                          label: 'ALLOY:',
                          value: bin.alloy,
                        ),
                        const SizedBox(height: 16),
                        CommonUi().infoRow(
                          context: context,
                          label: 'WEIGHT:',
                          value: bin.weight,
                        ),
                        const SizedBox(height: 16),
                        CommonUi().infoRow(
                          context: context,
                          label: 'BIN ZONE:',
                          value: bin.alloy,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ECC71),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          bottomRight: Radius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'LOADED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            CommonUi().primaryActionButton(
              context: context,
              icon: Icons.logout_rounded,
              label: 'UNLOAD BIN',
              color: const Color(0xFFE53935),
              onTap: onUnload,
            ),
          ],
        ),
        Positioned(top: 12, right: 0, child: ZoneBadge(zone: currentZone)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// SEARCH SCREEN ------------------------------------------------------------

class SearchScreen extends StatefulWidget {
  final List<BinInfo> bins;
  final VoidCallback onBack;
  final void Function(BinInfo bin) onSelectBinForLoad;

  const SearchScreen({
    super.key,
    required this.bins,
    required this.onBack,
    required this.onSelectBinForLoad,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  BinInfo? selected;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.bins.where((b) {
      if (query.isEmpty) return true;
      final q = query.toUpperCase();
      return b.id.contains(q) || b.alloy.toUpperCase().contains(q);
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textPrimary,
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
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: AppColors.blue,
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bin = filtered[index];
                    final isSelected = selected?.id == bin.id;
                    return GestureDetector(
                      onTap: () => setState(() => selected = bin),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    bin.id,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? AppColors.blue
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bin.alloy,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'WEIGHT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bin.weight,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7F0),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.6),
                    ),
                  ),
                  child: selected == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_rounded,
                              size: 60,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Select a bin to view details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            AppCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selected!.id,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _detailRow('Grade', selected!.alloy),
                                  const Divider(),
                                  _detailRow('Weight', selected!.weight),
                                  const Divider(),
                                  _detailRow('Location', selected!.zone),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.public_rounded,
                                      size: 60,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'No Zone Data Available',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
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
                                  backgroundColor: AppColors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () =>
                                    widget.onSelectBinForLoad(selected!),
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
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// OPTIONS SCREEN -----------------------------------------------------------

class OptionsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const OptionsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textPrimary,
              iconSize: 32,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Options',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: const [
            Expanded(
              child: AppCard(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: _OptionTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Driver Login',
                ),
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: AppCard(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: _OptionTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Vehicle Check',
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'LOG OUT SYSTEM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OptionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 40, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
