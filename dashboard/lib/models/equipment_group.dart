class EquipmentGroupApiDTO {
  /// Unique identifier for the equipment group event
  final int? id;

  /// Timestamp when this equipment group event was created
  final String? createdAt;

  /// Equipment group code
  final String? equipmentGroupCode;

  /// Equipment code within the group
  final String? equipmentCode;

  /// Severity level of the event (INFO, WARNING, ERROR, etc.)
  final String? severity;

  /// Type of the equipment group event
  final String? type;

  /// Title of the equipment group event
  final String? title;

  /// Detailed text content of the event
  final String? textContent;

  EquipmentGroupApiDTO({
    this.id,
    this.createdAt,
    this.equipmentGroupCode,
    this.equipmentCode,
    this.severity,
    this.type,
    this.title,
    this.textContent,
  });

  factory EquipmentGroupApiDTO.fromJson(Map<String, dynamic> json) {
    return EquipmentGroupApiDTO(
      id: json['id'] as int?,
      createdAt: json['createdAt'] as String?,
      equipmentGroupCode: json['equipmentGroupCode'] as String?,
      equipmentCode: json['equipmentCode'] as String?,
      severity: json['severity'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      textContent: json['textContent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'equipmentGroupCode': equipmentGroupCode,
      'equipmentCode': equipmentCode,
      'severity': severity,
      'type': type,
      'title': title,
      'textContent': textContent,
    };
  }
}
