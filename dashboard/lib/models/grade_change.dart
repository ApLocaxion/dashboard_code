class GradeChangeEventApiDTO {
  final int id;
  final String timestamp; // ISO-8601 UTC with microseconds
  final String? equipmentGroupCode;
  final String? equipmentCode;
  final String? lot;
  final String? grade;

  GradeChangeEventApiDTO({
    required this.id,
    required this.timestamp,
    this.equipmentGroupCode,
    this.equipmentCode,
    this.lot,
    this.grade,
  });

  factory GradeChangeEventApiDTO.fromJson(Map<String, dynamic> json) {
    return GradeChangeEventApiDTO(
      id: json['id'] as int,
      timestamp: json['timestamp'] as String,
      equipmentGroupCode: json['equipmentGroupCode'] as String?,
      equipmentCode: json['equipmentCode'] as String?,
      lot: json['lot'] as String?,
      grade: json['grade'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'equipmentGroupCode': equipmentGroupCode,
      'equipmentCode': equipmentCode,
      'lot': lot,
      'grade': grade,
    };
  }
}
