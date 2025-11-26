import 'dart:convert';

import 'package:dashboard/common/common_ui.dart';
import 'package:dashboard/common/common_widgets.dart';
import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/models/bin_model.dart';
import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:dashboard/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/service/bin_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoadedView extends StatefulWidget {
  const LoadedView({super.key});

  @override
  State<LoadedView> createState() => _LoadedViewState();
}

class _LoadedViewState extends State<LoadedView> {
  //
  final binController = Get.find<BinController>(tag: 'binController');
  final homePageController = Get.find<HomePageController>(
    tag: 'homePageController',
  );
  final containerController = Get.find<ContainerController>(
    tag: 'containerController',
  );
  BinModel? bin;

  int? index;
  load() async {
    await ContainerService().getAllForklift();
    index = containerController.containerList.indexWhere(
      (c) => c.slamCoreId == homePageController.deviceId.value,
    );
    setState(() {});
  }

  @override
  void initState() {
    load();
  }

  String currentZone(int? index, List<ContainerStateEventApiDTO> list) {
    if (index == null || index < 0 || index >= list.length) return "N/A";
    final z = list[index].zoneCode;
    return (z == null || z.isEmpty) ? "N/A" : z;
  }

  getAllBin() async {
    var response = await http.get(
      Uri.parse(
        "${Constants.baseApiUrilocal}/api/bins?binId=${binController.scanedBin.value}",
      ),
      headers: {"Content-type": "Application/json"},
    );
    // if response is sucessful
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      try {
        bin = BinModel.fromJson(data[0]);
      } catch (e) {
        print(e);
      }

      print(bin);
      return;
      //
    } else {
      CommonWidgets().errorSnackbar(
        'Error',
        'Unable to get bin  Data from server',
      );
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        binController.scanedBin.value == '';
      },
      child: Scaffold(
        body: FutureBuilder(
          future: getAllBin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // <-- prevents stretching
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    CommonUi().globalHeader(
                      wifiOnline: true,

                      deviceId: homePageController.deviceId.value,
                      context: context,
                      rtlsActive: true,
                      battery: 82,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 32),
                              Text(
                                'CURRENT LOAD',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "#${bin!.binId}",
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CommonUi().appCard(
                                context: context,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 0,
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        34,
                                        16,
                                        16,
                                      ),
                                      child: Column(
                                        children: [
                                          CommonUi().infoRow(
                                            context: context,
                                            label: 'ALLOY:',
                                            value: 'N/A',
                                          ),
                                          const SizedBox(height: 16),
                                          CommonUi().infoRow(
                                            context: context,
                                            label: 'WEIGHT:',
                                            value: 'N/A',
                                          ),
                                          const SizedBox(height: 16),
                                          CommonUi().infoRow(
                                            context: context,
                                            label: 'Location:',
                                            value:
                                                "On Forklift (${bin!.forkliftId})  ${bin!.zoneCode == null ? '' : '| #${bin!.zoneCode}'}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2ECC71),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(22),
                                          ),
                                        ),
                                        child: const Text(
                                          'LOADED',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              CommonUi().primaryActionButton(
                                context: context,
                                icon: Icons.logout_rounded,
                                label: 'UNLOAD BIN',
                                color: const Color(0xFFE53935),
                                onTap: () async {
                                  await BinService().loadBin(
                                    binController.scanedBin.value,
                                    "unload",
                                    deviceId:
                                        homePageController
                                            .simulateDeviceId
                                            .value
                                            .isEmpty
                                        ? homePageController.deviceId.value
                                        : homePageController
                                              .simulateDeviceId
                                              .value,
                                  );
                                  binController.scanedBin.value = "";
                                  Get.toNamed('/scan');
                                },
                              ),
                            ],
                          ),
                          Positioned(
                            top: 12,
                            right: 0,
                            child: CommonUi().appCard(
                              context: context,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'VEHICLE ZONE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                      Obx(() {
                                        final list =
                                            containerController.containerList;
                                        final zoneText = currentZone(
                                          index,
                                          list,
                                        );

                                        return Text(
                                          zoneText,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
