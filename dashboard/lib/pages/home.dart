import 'package:dashboard/common/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _ui = CommonUi();

  final List<_HomeTile> _tiles = const [
    _HomeTile(
      label: 'Driver Login',
      icon: Icons.grid_view_rounded,
      route: '/scan',
    ),
    _HomeTile(label: 'Simulate', icon: Icons.bolt_rounded, route: '/simulate'),
    _HomeTile(
      label: 'Dashboard',
      icon: Icons.dashboard_customize_rounded,
      route: '/dashboard',
    ),
  ];

  static const double tileSize = 200;
  static const double spacing = 16;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_tiles.length, (index) {
                final tile = _tiles[index];

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _tiles.length - 1 ? 0 : spacing,
                  ),
                  child: SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => Get.toNamed(tile.route),
                        child: _ui.appCard(
                          context: context,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(tile.icon, size: 32, color: colors.primary),
                              const SizedBox(height: 8),
                              Text(
                                tile.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile {
  const _HomeTile({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
