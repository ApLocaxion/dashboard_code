class MapConfig {
  final double mapWidth;
  final double mapHeight;
  final double marginMeters;
  final double pxPerMeter;

  const MapConfig({
    required this.mapWidth,
    required this.mapHeight,
    required this.marginMeters,
    required this.pxPerMeter,
  });

  MapConfig copyWith({
    double? mapWidth,
    double? mapHeight,
    double? marginMeters,
    double? pxPerMeter,
  }) {
    return MapConfig(
      mapWidth: mapWidth ?? this.mapWidth,
      mapHeight: mapHeight ?? this.mapHeight,
      marginMeters: marginMeters ?? this.marginMeters,
      pxPerMeter: pxPerMeter ?? this.pxPerMeter,
    );
  }
}
