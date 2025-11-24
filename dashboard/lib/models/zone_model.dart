class ZoneModel {
  final int id;
  final String code;
  final bool active;
  final String title;
  final String description;
  final List boundary;
  final double zMax;
  final double zMin;

  ZoneModel({
    required this.id,
    required this.code,
    required this.active,
    required this.title,
    required this.description,
    required this.boundary,
    required this.zMax,
    required this.zMin,
  });

  /// Factory constructor to create a Zone from JSON
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      active: json['active'] ?? false,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      boundary: json['boundary'] ?? [],
      zMax: (json['zmax'] ?? json['zMax'] ?? 0.0).toDouble(),
      zMin: (json['zmin'] ?? json['zMin'] ?? 0.0).toDouble(),
    );
  }

  /// Convert the Zone object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'active': active,
      'title': title,
      'description': description,
      'boundary': boundary,
      'zmax': zMax,
      'zmin': zMin,
    };
  }
}
