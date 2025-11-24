import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/zone-event.dart';
import 'package:dashboard/pages/dashboard/zoneEvent.dart';
import 'package:dashboard/service/zone_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');

  List<DataRow> zoneColumnsData = [];
  List<ZoneEventModel> events = [];
  bool sortAscending = true;
  int? sortColumnIndex;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    // get zone events
    await ZoneService().getAllzoneEvents();
    events = List.from(zoneController.allZoneEvent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          //
          zoneEvent(context),
        ],
      ),
    );
  }
}
