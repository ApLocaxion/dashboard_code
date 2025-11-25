class ScrapBin {
  final String id;
  final String alloy;
  final int weightLbs;
  final String zone;
  final String dwellTime; // Still store original string
  final String origin;
  final int capacityLbs;

  ScrapBin({
    required this.id,
    required this.alloy,
    required this.weightLbs,
    required this.zone,
    required this.dwellTime,
    required this.origin,
    this.capacityLbs = 2500,
  });

  // ---------- FROM JSON ----------
  factory ScrapBin.fromJson(Map<String, dynamic> json) {
    return ScrapBin(
      id: json['id']?.toString() ?? '',
      alloy: json['alloy']?.toString() ?? '',
      weightLbs: _parseInt(json['weightLbs'], fallback: 0),
      zone: json['zone']?.toString() ?? '',
      dwellTime: json['dwellTime']?.toString() ?? '0m',
      origin: json['origin']?.toString() ?? '',
      capacityLbs: _parseInt(json['capacityLbs'], fallback: 2500),
    );
  }

  // ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alloy': alloy,
      'weightLbs': weightLbs,
      'zone': zone,
      'dwellTime': dwellTime,
      'origin': origin,
      'capacityLbs': capacityLbs,
    };
  }

  // ---------- COPYWITH ----------
  ScrapBin copyWith({
    String? id,
    String? alloy,
    int? weightLbs,
    String? zone,
    String? dwellTime,
    String? origin,
    int? capacityLbs,
  }) {
    return ScrapBin(
      id: id ?? this.id,
      alloy: alloy ?? this.alloy,
      weightLbs: weightLbs ?? this.weightLbs,
      zone: zone ?? this.zone,
      dwellTime: dwellTime ?? this.dwellTime,
      origin: origin ?? this.origin,
      capacityLbs: capacityLbs ?? this.capacityLbs,
    );
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

  static List<ScrapBin> fromJsonList(List data) {
    return data.map((e) => ScrapBin.fromJson(e)).toList();
  }
}
