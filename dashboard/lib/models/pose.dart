class Pose {
  final double x;
  final double y;
  final double z;

  Pose({required this.x, required this.y, required this.z});

  factory Pose.fromJson(Map<String, dynamic> json) {
    return Pose(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      z: (json['z'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};
}
