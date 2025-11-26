import 'dart:async';

import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/service/bin_service.dart';
import 'package:dashboard/pages/scan/ready.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );

  final binController = Get.find<BinController>(tag: 'binController');

  bool _showVirtualKeyboard = false;
  bool _numericOnly =
      false; // flip to true if you want a numeric keypad by default

  bool get _isDesktopWeb =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleKeyboard() {
    setState(() => _showVirtualKeyboard = !_showVirtualKeyboard);
    if (_showVirtualKeyboard) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  void _insertText(String text) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.start >= 0 ? selection.start : value.text.length;
    final end = selection.end >= 0 ? selection.end : value.text.length;

    final newText = value.text.replaceRange(start, end, text);
    final caret = start + text.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: caret),
    );
  }

  void _backspace() {
    final value = _controller.value;
    final selection = value.selection;

    if (selection.start != selection.end) {
      // delete selected range
      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        '',
      );
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    final caret = selection.start;
    if (caret <= 0) return;

    final newText = value.text.replaceRange(caret - 1, caret, '');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: caret - 1),
    );
  }

  int? index;
  load() async {
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
    await ContainerService().getAllForklift();
    index = containerController.containerList.indexWhere(
      (c) => c.slamCoreId == homePageController.deviceId.value,
    );
    setState(() {});
  }

  @override
  void initState() {
    load();
  }

  // state fields
  OverlayEntry? _confirmOverlay;

  void _showConfirmOverlay() {
    final binId = binController.scanedBin.value.trim();
    if (binId.isEmpty) {
      CommonWidgets().errorSnackbar("ERROR", 'ENTER BIN ID');
      return;
    }
    if (_confirmOverlay != null) return;
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _confirmOverlay = OverlayEntry(
      builder: (_) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            const ModalBarrier(color: Colors.black54),
            Center(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width - 250,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        right: 0,
                        child: CommonUi().appCard(
                          context: context,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'VEHICLE ZONE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  Text(
                                    currentZone(index),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'ARE YOU LOADING BIN?',
                              style: TextStyle(
                                fontSize: size.height / 30,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              binController.scanedBin.value.trim(),
                              style: TextStyle(
                                fontSize: size.height / 18,
                                fontWeight: FontWeight.w900,

                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: size.height / 20),
                            CommonUi().appCard(
                              context: context,
                              padding: EdgeInsets.symmetric(
                                horizontal: size.height / 21,
                                vertical: size.height / 30,
                              ),
                              child: Column(
                                children: [
                                  CommonUi().infoRow(
                                    context: context,
                                    label: 'ALLOY:',
                                    value: 'N/A',
                                  ),
                                  Divider(
                                    height: size.height / 21,
                                    thickness: 1,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  CommonUi().infoRow(
                                    context: context,
                                    label: 'WEIGHT:',
                                    value: 'N/A',
                                  ),
                                  Divider(
                                    height: size.height / 21,
                                    thickness: 1,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  CommonUi().infoRow(
                                    context: context,
                                    label: 'LOCATION:',
                                    value: 'N/A',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height / 21),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: CommonUi().primaryActionButton(
                          context: context,
                          icon: Icons.error_outline_rounded,
                          label: 'NO',
                          color: const Color(0xFFE53935),
                          onTap: () {
                            _removeConfirmOverlay();
                            _controller.clear();
                            _focusNode.requestFocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: CommonUi().primaryActionButton(
                          context: context,
                          icon: Icons.check_circle_outline_rounded,
                          label: 'YES',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () async {
                            homePageController.scan.value = false;
                            // homePageController.manualEntry.value = false;
                            _controller.clear();
                            _removeConfirmOverlay();
                            Get.toNamed(
                              "/load",
                              arguments: {'binId': 'BIN_12345'},
                            );
                            final binId = binController.scanedBin.value.trim();
                            await BinService().loadBin(
                              binId,
                              "load",
                              deviceId:
                                  homePageController
                                      .simulateDeviceId
                                      .value
                                      .isEmpty
                                  ? homePageController.deviceId.value
                                  : homePageController.simulateDeviceId.value,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_confirmOverlay!);
    _focusNode.requestFocus(); // keep the main field active
  }

  void _removeConfirmOverlay() {
    _confirmOverlay?.remove();
    _confirmOverlay = null;
  }

  String currentZone(index) {
    if (index == null || index == -1) return "N/A";
    final z = containerController.containerList[index].zoneCode;
    return (z == null || z.isEmpty) ? "N/A" : z;
  }

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    // On mobile, autofocus helps pop the native keyboard. On desktop web we keep it false.
    final useAutofocus = !_isDesktopWeb;

    return Scaffold(
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonUi().globalHeader(
                wifiOnline: true,
                context: context,
                deviceId: homePageController.deviceId.value,
                rtlsActive: true,
                battery: 82,
              ),
              ScanScreen(
                currentZone: currentZone(index),
                speed: 'N/A',
                shiftTime: 'N/A',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommonUi().appCard(
                  context: context,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 6.8,
                              child: CommonUi().primaryActionButtonHorzontal(
                                color: !homePageController.scan.value
                                    ? Colors.red
                                    : Colors.green,
                                onTap: () {
                                  homePageController.scan.value =
                                      !homePageController.scan.value;
                                  if (homePageController.scan.value) {
                                    _focusNode.requestFocus();
                                  }
                                },
                                context: context,
                                icon: Icons.qr_code_scanner,
                                label: !homePageController.scan.value
                                    ? "Paused"
                                    : "Scanning",
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                child: KeyboardListener(
                                  focusNode: FocusNode(),
                                  autofocus: true,
                                  onKeyEvent: (event) {},
                                  child: TextFormField(
                                    controller: _controller,

                                    focusNode: _focusNode,
                                    textAlign: TextAlign.center,
                                    readOnly: !(homePageController.scan.value),
                                    textInputAction: TextInputAction.done,

                                    onChanged: (value) {
                                      _focusNode.requestFocus();
                                      if (homePageController
                                          .manualEntry
                                          .value) {
                                        //
                                        final upper = value.toUpperCase();
                                        if (value != upper) {
                                          _controller.value = _controller.value
                                              .copyWith(
                                                text: upper,
                                                selection:
                                                    TextSelection.collapsed(
                                                      offset: upper.length,
                                                    ),
                                              );
                                        }
                                        binController.scanedBin.value = value
                                            .toUpperCase();
                                      } else {
                                        _debounce
                                            ?.cancel(); // Cancel previous timer
                                        _debounce = Timer(
                                          Duration(milliseconds: 50),
                                          () {
                                            if (value ==
                                                binController.scanedBin.value) {
                                              return;
                                            }
                                            if (homePageController.scan.value) {
                                              binController.scanedBin.value =
                                                  '';
                                              final upper = value.toUpperCase();
                                              if (value != upper) {
                                                _controller.value = _controller
                                                    .value
                                                    .copyWith(
                                                      text: upper,
                                                      selection:
                                                          TextSelection.collapsed(
                                                            offset:
                                                                upper.length,
                                                          ),
                                                    );
                                              }
                                              binController.scanedBin.value =
                                                  value.toUpperCase();
                                              _controller.clear();
                                            }
                                          },
                                        );
                                      }
                                    },
                                    onFieldSubmitted: (value) {
                                      _showConfirmOverlay();
                                      _focusNode.requestFocus();
                                    },
                                    cursorColor:
                                        Colors.black, // or a brand color
                                    cursorWidth: 2.0,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                          14, // 🔥 text size
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textCapitalization:
                                        TextCapitalization.characters,

                                    decoration: InputDecoration(
                                      labelText: 'SCAN OR TYPE BIN ID',
                                      prefixText: binController.scanedBin.value,

                                      border: const OutlineInputBorder(),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                            255,
                                            94,
                                            204,
                                            255,
                                          ),
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Tooltip(
                                            message: _showVirtualKeyboard
                                                ? 'Hide virtual keyboard'
                                                : 'Show virtual keyboard',
                                            child: IconButton(
                                              icon: const Icon(Icons.keyboard),
                                              iconSize: 35,
                                              onPressed: _toggleKeyboard,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      // If user taps field while keyboard is visible, keep focus
                                      if (_showVirtualKeyboard)
                                        _focusNode.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                              color: homePageController.scan.value
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            homePageController.scan.value
                                ? 'SCANNER READY & ACTIVE'
                                : 'SCANNER DISCONNECTED',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: homePageController.scan.value
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (!_showVirtualKeyboard)
                // BOTTOM BUTTONS
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonUi().primaryActionButton(
                          context: context,
                          icon: Icons.keyboard_rounded,
                          label: 'MANUAL ENTRY',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            _showVirtualKeyboard = true;
                            // homePageController.manualEntry.value =
                            //     !homePageController.manualEntry.value;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CommonUi().primaryActionButton(
                          context: context,
                          icon: Icons.search_rounded,
                          label: 'SEARCH BINS',
                          color: Colors.white,
                          onTap: () {
                            Get.toNamed('/searchScreen');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // In-app keyboard (desktop web or whenever toggled on)
              if (_showVirtualKeyboard)
                _VirtualKeyboard(
                  numericOnly: _numericOnly,
                  onKey: _insertText,
                  onBackspace: _backspace,
                  onSpace: () => _insertText(' '),
                  onEnter: () {
                    // Up to you: submit or just insert newline
                    // _insertText('\n');
                    _showConfirmOverlay();
                    _focusNode.requestFocus();
                    debugPrint('Entered value: ${_controller.text}');
                    FocusScope.of(context).unfocus();
                    setState(() => _showVirtualKeyboard = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lightweight in-app virtual keyboard for web/desktop.
/// No external packages; easy to style or swap with a package later.
class _VirtualKeyboard extends StatelessWidget {
  final bool numericOnly;
  final VoidCallback onBackspace;
  final VoidCallback onEnter;
  final VoidCallback onSpace;
  final void Function(String) onKey;

  const _VirtualKeyboard({
    required this.numericOnly,
    required this.onBackspace,
    required this.onEnter,
    required this.onSpace,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceVariant;
    final Size size = MediaQuery.of(context).size;

    return Material(
      elevation: 8,
      color: bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in _qwertyRows())
              _KeyRow(keys: row, size: size, onKey: onKey),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Key(
                    label: 'Space',
                    size: size,
                    flex: 6,
                    onTap: onSpace,
                  ),
                ),
                const SizedBox(width: 8),
                _IconKey(icon: Icons.backspace, onTap: onBackspace),
                const SizedBox(width: 8),
                _Key(label: 'Done', size: size, onTap: onEnter),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<List<String>> _qwertyRows() => const [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '_', '-'],
  ];
}

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final Size size;
  final void Function(String) onKey;

  const _KeyRow({required this.keys, required this.size, required this.onKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.width / 100),
      child: Row(
        children: [
          for (final k in keys) ...[
            _Key(label: k, size: size, onTap: () => onKey(k)),
            SizedBox(width: size.width / 80),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String label;
  final int flex;
  final Size size;
  final VoidCallback onTap;

  const _Key({
    required this.label,
    required this.size,
    required this.onTap,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(minimumSize: const Size(48, 44)),
      child: Text(label, style: TextStyle(fontSize: size.width / 65)),
    );
    return Expanded(flex: flex, child: btn);
  }
}

class _IconKey extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconKey({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(minimumSize: const Size(64, 44)),
      child: Icon(icon),
    );
  }
}
