import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const DashboardCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.tertiary,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: borderColor ?? colors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 24,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
