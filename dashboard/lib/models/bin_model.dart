class BinModel {
  final String binId;
  final String status;
  final String? forkliftId;
  final String? zoneCode;

  // Newly added nullable scrap-bin style fields
  final String? alloy;
  final int weightLbs;
  final String dwellTime;
  final String? origin;
  final int capacityLbs;

  // Position info (flat, not nested)
  final double x;
  final double y;
  final double z;
  final DateTime? timeStamp;

  // Metadata timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BinModel({
    required this.binId,
    required this.status,
    this.forkliftId,
    this.zoneCode,
    this.alloy,
    this.origin,
    required this.weightLbs,
    required this.dwellTime,
    required this.capacityLbs,
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

      // New fields
      alloy: json['alloy'],
      weightLbs: json['weightLbs'],
      dwellTime: json['dwellTime'],
      origin: json['origin'],
      capacityLbs: json['capacityLbs'],

      // position
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
      // New fields
      'alloy': alloy,
      'weightLbs': weightLbs,
      'dwellTime': dwellTime,
      'origin': origin,
      'capacityLbs': capacityLbs,

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

  // ---------- HELPERS ----------
  String get weightKg => (weightLbs * 0.453592).round().toString();

  String get weightLbsStr => weightLbs.toString();

  double get fillPercentage => (weightLbs / capacityLbs).clamp(0.0, 1.0);

  /// Parses '2h 30m' → Duration
  Duration get dwellDuration {
    int mins = 0;
    for (final part in dwellTime.split(' ')) {
      if (part.endsWith('h')) {
        mins += int.tryParse(part.replaceAll('h', ''))! * 60;
      } else if (part.endsWith('m')) {
        mins += int.tryParse(part.replaceAll('m', ''))!;
      }
    }
    return Duration(minutes: mins);
  }

  int get dwellMinutes => dwellDuration.inMinutes;

  // ---------- STATIC UTIL ----------
  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
