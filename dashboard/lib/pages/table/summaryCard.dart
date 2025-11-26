import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.tertiary),
          boxShadow: [
            BoxShadow(
              color: const Color(0x08000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colors.onSurfaceVariant,
                size: size.width / 42,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size.width / 90,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: size.width / 50,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
