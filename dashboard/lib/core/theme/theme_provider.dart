import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // .obs makes this variable "observable"
  final _themeMode = ThemeMode.system.obs;

  // Getter to access the value
  ThemeMode get themeMode => _themeMode.value;

  // Call this method from your UI to change the theme
  void changeTheme(ThemeMode newMode) {
    _themeMode.value = newMode;
    // This tells GetMaterialApp to update
    Get.changeThemeMode(newMode);

    // You can add logic here to save the theme to SharedPreferences
  }
}
