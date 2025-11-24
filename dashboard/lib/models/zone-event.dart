import 'package:dashboard/models/pose.dart';

class ZoneEventModel {
  final String deviceId;
  final String event; // "enter" | "exit"
  final String zone;
  final String timestamp;
  final Pose pose;

  ZoneEventModel({
    required this.deviceId,
    required this.event,
    required this.zone,
    required this.timestamp,
    required this.pose,
  });

  factory ZoneEventModel.fromJson(Map<String, dynamic> json) {
    return ZoneEventModel(
      deviceId: json['deviceId'] ?? '',
      event: json['event'] ?? '',
      zone: json['zone'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      pose: Pose.fromJson(json['pose'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'event': event,
    'zone': zone,
    'timestamp': timestamp,
    'pose': pose.toJson(),
  };
}
