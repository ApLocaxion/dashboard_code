import 'package:dashboard/models/bin_model.dart';
import 'package:get/get.dart';

class BinController extends GetxController {
  ///
  ///List
  var allBin = <BinModel>[].obs;

  final Rxn<BinModel> selectedBin = Rxn<BinModel>();

  final isLoaded = false.obs;

  final scanedBin = ''.obs;
}
