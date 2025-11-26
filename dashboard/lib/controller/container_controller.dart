import 'package:dashboard/models/container_event.dart';
import 'package:dashboard/models/pose.dart';
import 'package:get/get.dart';

class ContainerController extends GetxController {
  //
  final RxList<ContainerStateEventApiDTO> containerList =
      <ContainerStateEventApiDTO>[].obs;

  final selectedContainerCode = ''.obs;
  final currentZone = RxnString(); // nullable

  final showTrajector = false.obs;

  //
  final selectedContainer = Rx<ContainerStateEventApiDTO?>(null);

  //
  final RxList<Pose> trajectory = <Pose>[].obs;
}
