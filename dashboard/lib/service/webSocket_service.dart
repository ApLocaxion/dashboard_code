import 'dart:convert';

import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/models/pose.dart';
import 'package:dashboard/service/bin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//
class WebsocketService {
  WebSocketChannel? _channel;
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  final webSocketController = Get.find<WebSocketController>(
    tag: 'webSocketController',
  );

  /// Connect to WebSocket
  void connectWebSocket(String wsUrl) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      webSocketController.isConnected.value = true;

      print(' WebSocket connected: $wsUrl');

      _channel!.stream.listen(
        (data) => _handleIncomingData(data),
        onDone: () {
          print(' WebSocket closed');
          webSocketController.isConnected.value = false;
        },
        onError: (error) {
          print(' WebSocket error: $error');
          webSocketController.isConnected.value = false;
        },
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  /// Handle incoming data
  void _handleIncomingData(dynamic data) async {
    try {
      final decodedRaw = jsonDecode(data);

      if (decodedRaw is! Map) {
        print(
          '! Error parsing data: Expected Map but got ${decodedRaw.runtimeType}',
        );
        return;
      }

      final decoded = Map<String, dynamic>.from(decodedRaw);
      final String? type = decoded['type'] as String?;

      if (type == 'pose' || type == 'simulate') {
        final poseRaw = decoded['pose'];
        final deviceId = decoded['deviceId'];

        if (poseRaw is Map) {
          final poseMap = Map<String, dynamic>.from(poseRaw);
          final px = (poseMap['x'] as num?)?.toDouble() ?? 0;
          final py = (poseMap['y'] as num?)?.toDouble() ?? 0;
          final pz = (poseMap['z'] as num?)?.toDouble() ?? 0;

          if (containerController.containerList.isNotEmpty) {
            final index = containerController.containerList.indexWhere(
              (c) => c.slamCoreId == deviceId,
            );

            if (index != -1) {
              containerController.containerList[index].x = px;
              containerController.containerList[index].y = py;
            }
          }

          containerController.trajectory.add(Pose(x: px, y: py, z: pz));
          containerController.containerList.refresh();
        }
      } else if (type == 'zone') {
        final transitionRaw = decoded['transition'];
        if (transitionRaw is Map) {
          final transition = Map<String, dynamic>.from(transitionRaw);
          final deviceId = transition['deviceId'];
          final event = transition['event'];
          final zone = transition['zone'];
          final timestamp = transition['timestamp'];
          // final pose = transition['pose'];

          if (event == "exit") {
            //
            containerController.currentZone.value = null;
          } else if (containerController.containerList.isNotEmpty) {
            final index = containerController.containerList.indexWhere(
              (c) => c.slamCoreId == deviceId,
            );
            if (index != -1 && event == "enter") {
              containerController.containerList[index].zoneCode = zone;
              containerController.currentZone.value = zone;
            }
          }
          containerController.containerList.refresh();
          Get.closeAllSnackbars();
          Get.snackbar(
            'zone event',
            "Device id: '$deviceId' $event $zone at $timestamp",
            snackPosition: SnackPosition.BOTTOM,
            snackStyle: SnackStyle
                .FLOATING, // <-- Makes it floating instead of full width
            maxWidth: 300, // <-- Set required width
            margin: const EdgeInsets.only(
              bottom: 50,
            ), // <-- Adds space from bottom

            backgroundColor: Colors.white,
            colorText: Colors.black,
            duration: const Duration(seconds: 3),
            borderRadius: 12,

            // ✅ Black border
            borderColor: Colors.black,
            borderWidth: 2,
          );
        }
      } else if (type == 'containers') {
        // Optional: update entire container list from a list payload
        final listRaw = decoded['containers'];
        if (listRaw is List) {
          final items = listRaw
              .map(
                (e) => ContainerStateEventApiDTO.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
          containerController.containerList.assignAll(items);
        }
      } else if (type == 'bin') {
        await BinService().getAllBin();
        return;
      }

      // // Example fallback matching by device id
      // if (type == 'pose') {
      //   final slamId = decoded['deviceId'];
      //   if (slamId != null) {
      //     for (final c in containerController.containerList) {
      //       if (c.slamCoreId == slamId) {
      //         final pose = Map<String, dynamic>.from(decoded['pose'] as Map);
      //         c.x = (pose['x'] as num?)?.toDouble() ?? c.x;
      //         c.y = (pose['y'] as num?)?.toDouble() ?? c.y;
      //       }
      //     }
      //     containerController.containerList.refresh();
      //   }
      // }
    } catch (e) {
      print(' Error parsing data: $e');
    }
  }
}
