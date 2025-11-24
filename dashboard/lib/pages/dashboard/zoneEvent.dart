import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/models/zone-event.dart';
import 'package:dashboard/service/zone_service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Widget zoneEvent(BuildContext context) {
  return ZoneEventTable();
}

class ZoneEventTable extends StatefulWidget {
  const ZoneEventTable({super.key});

  @override
  State<ZoneEventTable> createState() => _ZoneEventTableState();
}

class _ZoneEventTableState extends State<ZoneEventTable> {
  final zoneController = Get.find<ZoneController>(tag: 'zoneController');
  List<ZoneEventModel> events = [];
  bool sortAscending = true;

  void _sort<T>(Comparable<T> Function(ZoneEventModel e) getField) {
    events.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return sortAscending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    sortAscending = !sortAscending;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    await ZoneService().getAllzoneEvents();
    events = List.from(zoneController.allZoneEvent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 1.5,
        child: DataTableTheme(
          data: DataTableThemeData(
            dividerThickness: 1,
            dataRowColor: WidgetStateProperty.all(Colors.red),
            headingRowColor: WidgetStateProperty.all(Colors.red),
          ),
          child: DataTable2(
            columnSpacing: 12,
            sortColumnIndex: 1,
            horizontalMargin: 12,
            showBottomBorder: true,
            border: TableBorder(
              top: const BorderSide(color: Colors.grey, width: 1),
              right: const BorderSide(color: Colors.grey, width: 1),
              bottom: const BorderSide(color: Colors.grey, width: 1),
              left: const BorderSide(color: Colors.grey, width: 1),
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 0.8,
              ),
              verticalInside: BorderSide(
                color: Colors.grey.shade300,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            minWidth: 300,
            columns: [
              DataColumn(
                label: Text('Device-Id'),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text('Event'),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text('Geo-fenc'),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text('Time'),
                headingRowAlignment: MainAxisAlignment.center,
                onSort: (_, _) =>
                    _sort((e) => DateTime.parse(e.timestamp.toString())),
                tooltip: 'sort',
                numeric: true,
              ),
              // DataColumn(
              //   label: Text('Position'),
              //   headingRowAlignment: MainAxisAlignment.center,
              // ),
            ],
            rows: events.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e.deviceId)),
                  DataCell(Text(e.event)),
                  DataCell(Text(e.zone)),
                  DataCell(
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(
                        DateTime.parse(e.timestamp.toString()).toLocal(),
                      ),
                    ),
                  ),
                  // DataCell(
                  //   Text(
                  //     "X: ${e.pose.x.toStringAsFixed(2)}, Y: ${e.pose.y.toStringAsFixed(2)}, Z: ${e.pose.z.toStringAsFixed(2)}",
                  //   ),
                  // ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
