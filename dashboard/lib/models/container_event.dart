class ContainerStateEventApiDTO {
  final String lastModified; // ISO-8601 UTC with microseconds
  final String slamCoreId;
  String? zoneCode;
  double x;
  double y;
  final double? z;

  ContainerStateEventApiDTO({
    required this.lastModified,
    required this.slamCoreId,
    this.zoneCode,
    required this.x,
    required this.y,
    this.z,
  });

  factory ContainerStateEventApiDTO.fromJson(Map<String, dynamic> json) {
    final pose = json['pose'] ?? {};

    return ContainerStateEventApiDTO(
      lastModified: pose['timestamp'] ?? '',
      slamCoreId: json['slamCoreId'] ?? '',
      zoneCode: json['zoneCode'] ?? '',
      x: (pose['x']).toDouble(),
      y: (pose['y']).toDouble(),
      z: (pose['z']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastModified': lastModified,
      'slamCoreId': slamCoreId,
      'zoneCode': zoneCode,
      'x': x,
      'y': y,
      'z': z,
    };
  }
}
