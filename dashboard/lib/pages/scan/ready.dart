import 'package:dashboard/common/common_ui.dart';
import 'package:flutter/material.dart';

class ScanScreen extends StatefulWidget {
  final String currentZone;
  final String speed;
  final String shiftTime;

  const ScanScreen({
    super.key,
    required this.currentZone,
    required this.speed,
    required this.shiftTime,
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.height / 40),
      child: SizedBox(
        height: size.height / 4,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: CommonUi().appCard(
                context: context,
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: size.height / 40,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Ready to Load',
                            style: TextStyle(
                              fontSize: size.height / 20,
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(height: size.height / 40),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: size.height / 22,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT OPERATOR',
                                    style: TextStyle(
                                      fontSize: size.height / 55,
                                      fontWeight: FontWeight.w800,
                                      color: colors.onSurfaceVariant,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'DF01 ',
                                          style: TextStyle(
                                            fontSize: size.height / 31,
                                            fontWeight: FontWeight.w800,

                                            color: colors.onSurface,
                                          ),
                                        ),
                                        // TextSpan(
                                        //   text: '(Tap to login)',
                                        //   style: TextStyle(
                                        //     fontSize: 16,
                                        //     fontWeight: FontWeight.w600,
                                        //     color: colors.primary,
                                        //   ),
                                        // ),
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
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CURRENT ZONE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurfaceVariant,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.location_on,

                                color: colors.primary,
                                size: 26,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.currentZone,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: size.height / 18,
                                    fontWeight: FontWeight.w900,

                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.height / 40),
            Expanded(
              flex: 1,
              child: CommonUi().matrixCard(
                context: context,
                icon: Icons.monitor_heart_rounded,
                label: 'Speed',
                value: widget.speed,
              ),
            ),
            SizedBox(width: size.height / 40),
            Expanded(
              flex: 1,
              child: CommonUi().matrixCard(
                context: context,
                icon: Icons.schedule_rounded,
                label: 'Shift Time',
                value: widget.shiftTime,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
