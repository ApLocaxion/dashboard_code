class ForkliftLoadedEventApiDTO {
  final int id;
  final String timestamp; // ISO-8601 UTC with microseconds
  final String equipmentGroupCode;
  final String equipmentCode;
  final bool loaded;
  final String? loadCode;
  final double? x;
  final double? y;
  final double? z;
  final String? rtlsZoneCode;
  final String? rtlsZoneTitle;

  ForkliftLoadedEventApiDTO({
    required this.id,
    required this.timestamp,
    required this.equipmentGroupCode,
    required this.equipmentCode,
    required this.loaded,
    this.loadCode,
    this.x,
    this.y,
    this.z,
    this.rtlsZoneCode,
    this.rtlsZoneTitle,
  });

  factory ForkliftLoadedEventApiDTO.fromJson(Map<String, dynamic> json) {
    return ForkliftLoadedEventApiDTO(
      id: json['id'] as int,
      timestamp: json['timestamp'] as String,
      equipmentGroupCode: json['equipmentGroupCode'] as String,
      equipmentCode: json['equipmentCode'] as String,
      loaded: json['loaded'] as bool,
      loadCode: json['loadCode'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      z: (json['z'] as num?)?.toDouble(),
      rtlsZoneCode: json['rtlsZoneCode'] as String?,
      rtlsZoneTitle: json['rtlsZoneTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'equipmentGroupCode': equipmentGroupCode,
      'equipmentCode': equipmentCode,
      'loaded': loaded,
      'loadCode': loadCode,
      'x': x,
      'y': y,
      'z': z,
      'rtlsZoneCode': rtlsZoneCode,
      'rtlsZoneTitle': rtlsZoneTitle,
    };
  }
}
