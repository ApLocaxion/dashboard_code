class BinModel {
  final String binId;
  final String status;
  final String? forkliftId;
  final String? zoneCode;

  // Optional business fields (local/UI use)
  final List<String>? grades;
  final double? weight; // lbs
  final bool? mixedGrade;
  final String? description;

  // Position info (nullable)
  final double x;
  final double y;
  final double z;
  final DateTime? timeStamp;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  BinModel({
    required this.binId,
    required this.status,
    this.forkliftId,
    this.zoneCode,
    this.grades,
    this.weight,
    this.mixedGrade,
    this.description,
    required this.x,
    required this.y,
    required this.z,
    this.timeStamp,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory: create from backend JSON
  factory BinModel.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] ?? {};

    return BinModel(
      binId: json['binId'] ?? '',
      status: json['status'] ?? '',
      forkliftId: json['forkliftId'],
      zoneCode: json['zoneCode'],
      grades: (json['grades'] as List?)?.cast<String>() ?? [],
      weight: (json['weight'] != null)
          ? (json['weight'] as num).toDouble()
          : null,
      mixedGrade: json['mixedGrade'] ?? false,
      description: json['description'] ?? '',
      x: (pos['x'] as num?)?.toDouble() ?? 0.0,
      y: (pos['y'] as num?)?.toDouble() ?? 0.0,
      z: (pos['z'] as num?)?.toDouble() ?? 0.0,

      timeStamp: pos['timestamp'] != null
          ? DateTime.tryParse(pos['timestamp'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert model to JSON (for sending updates)
  Map<String, dynamic> toJson() {
    return {
      'binId': binId,
      'status': status,
      'forkliftId': forkliftId,
      'zoneCode': zoneCode,
      'grades': grades,
      'weight': weight,
      'mixedGrade': mixedGrade,
      'description': description,
      'position': {
        'x': x,
        'y': y,
        'z': z,
        'timestamp': timeStamp?.toIso8601String(),
      },
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
