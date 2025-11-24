import 'package:dashboard/models/bin_model.dart';
import 'package:get/get.dart';

class BinController extends GetxController {
  ///
  ///List
  var allBin = <BinModel>[].obs;

  final isLoaded = false.obs;

  final scanedBin = ''.obs;
}
