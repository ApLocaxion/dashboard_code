class AlertApiDTO {
  final int id;
  final String createdAt; // ISO-8601 UTC with microseconds
  final int? equipmentGroupId;
  final int? equipmentId;
  final String
  severity; // Assuming AlertSeverity is an enum represented as string
  final String type;
  final String title;
  final String? textContent;

  AlertApiDTO({
    required this.id,
    required this.createdAt,
    this.equipmentGroupId,
    this.equipmentId,
    required this.severity,
    required this.type,
    required this.title,
    this.textContent,
  });

  factory AlertApiDTO.fromJson(Map<String, dynamic> json) {
    return AlertApiDTO(
      id: json['id'] as int,
      createdAt: json['createdAt'] as String,
      equipmentGroupId: json['equipmentGroupId'] as int?,
      equipmentId: json['equipmentId'] as int?,
      severity: json['severity'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      textContent: json['textContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'equipmentGroupId': equipmentGroupId,
      'equipmentId': equipmentId,
      'severity': severity,
      'type': type,
      'title': title,
      'textContent': textContent,
    };
  }
}
