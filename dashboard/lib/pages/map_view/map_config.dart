import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Matches your areaMap config
class MapConfig {
  final double widthMeters;
  final double heightMeters;
  final double marginMeters;
  final double pxPerMeter;
  const MapConfig({
    required this.widthMeters,
    required this.heightMeters,
    required this.marginMeters,
    required this.pxPerMeter,
  });

  double get totalWidthMeters => widthMeters + 2 * marginMeters;
  double get totalHeightMeters => heightMeters + 2 * marginMeters;

  /// World origin in meters (negative margin so world coords include the margin)
  double get originX => -marginMeters;
  double get originY => -marginMeters;
}
