import 'package:dashboard/models/bin_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchControllerQuery extends GetxController {
  ///
  final searchQuery = TextEditingController().obs;

  var results = <BinModel>[].obs;
}
