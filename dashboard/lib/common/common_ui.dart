import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonUi {
  Widget rowIcon({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
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

  Widget detailRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget columnIcon({
    required IconData icon,
    required BuildContext context,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 40, color: colors.onSurface),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget globalHeader({
    required bool wifiOnline,
    required BuildContext context,
    required String deviceId,
    required bool rtlsActive,
    required double battery,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.secondary,
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
                  children: [
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
                      deviceId,
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

          const SizedBox(width: 20),
          Text(
            'ScrapView™',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 100),

          // Right: Status pills + battery
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              rowIcon(
                // context: context,
                icon: Icons.wifi_rounded,
                label: wifiOnline ? 'On-Line' : 'Offline',
              ),
              const SizedBox(width: 8),
              rowIcon(
                // context: context,
                icon: Icons.signal_cellular_alt_rounded,
                label: rtlsActive ? 'RTLS Active' : 'RTLS Down',
              ),
              const SizedBox(width: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 2,
                height: 24,
                color: Colors.white24,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(battery * 1).round()}%',
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

  Widget appCard({
    required Widget child,
    required BuildContext context,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    EdgeInsetsGeometry? margin,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.tertiary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget infoRow({
    required String label,
    required String value,
    required,
    required BuildContext context,
  }) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.height / 38,
              fontWeight: FontWeight.w900,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: size.height / 25,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget matrixCard({
    required BuildContext context,
    required String label,
    String unit = '',
    required String value,
    required IconData icon,
  }) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    return appCard(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value${unit.isNotEmpty ? ' $unit' : ''}',
            style: TextStyle(
              fontSize: size.height / 18,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget primaryActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: size.height / 7,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color == Colors.white ? colors.onSurfaceVariant : color,
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
                color: color == Colors.white ? colors.primary : Colors.white,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color == Colors.white
                      ? colors.onSurface
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget horizontalDivider({double height = 32}) {
    return Divider(height: height, thickness: 1, color: Color(0xFFE5E7EB));
  }

  Widget verticalDivider() {
    return VerticalDivider(width: 32, thickness: 2, color: Color(0xFFE5E7EB));
  }
}
