class OutputPositionEventApiDTO {
  final int id;
  final String timestamp; // ISO UTC with microseconds
  final String? equipmentGroupCode;
  final List<String>? grades;
  final String? containerCode;
  final int hopperPosition;
  final bool outputActive;
  final bool mixedGrade;

  OutputPositionEventApiDTO({
    required this.id,
    required this.timestamp,
    this.equipmentGroupCode,
    this.grades,
    this.containerCode,
    required this.hopperPosition,
    required this.outputActive,
    required this.mixedGrade,
  });

  factory OutputPositionEventApiDTO.fromJson(Map<String, dynamic> json) {
    return OutputPositionEventApiDTO(
      id: json['id'] as int,
      timestamp: json['timestamp'] as String,
      equipmentGroupCode: json['equipmentGroupCode'] as String?,
      grades: (json['grades'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      containerCode: json['containerCode'] as String?,
      hopperPosition: json['hopperPosition'] as int,
      outputActive: json['outputActive'] as bool,
      mixedGrade: json['mixedGrade'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'equipmentGroupCode': equipmentGroupCode,
      'grades': grades,
      'containerCode': containerCode,
      'hopperPosition': hopperPosition,
      'outputActive': outputActive,
      'mixedGrade': mixedGrade,
    };
  }
}
