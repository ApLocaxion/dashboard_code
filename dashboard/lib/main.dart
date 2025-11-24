import 'package:dashboard/controller/bin_controller.dart';
import 'package:dashboard/controller/container_controller.dart';
import 'package:dashboard/controller/dashboard_controller.dart';
import 'package:dashboard/controller/home_controller.dart';
import 'package:dashboard/controller/map_controller.dart';
import 'package:dashboard/controller/search_controller.dart';
import 'package:dashboard/controller/webSocket_controller.dart';
import 'package:dashboard/controller/zone_controller.dart';
import 'package:dashboard/core/routes.dart';
import 'package:dashboard/core/theme/theme_provider.dart';
import 'package:dashboard/service/home_service.dart';
// import 'package:dashboard/core/theme/theme_provider.dart'; // <-- No longer needed
// import 'package:dashboard/service/home_service.dart'; // <-- Moved to controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/theme.dart';
// import 'package:provider/provider.dart'; // <-- No longer needed

void main() {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  //  setPathUrlStrategy();

  // Put your GetX controllers
  Get.put(HomePageController(), tag: 'homePageController');
  Get.put(WebSocketController(), tag: 'webSocketController');
  Get.put(MapController(), tag: 'mapController');
  Get.put(ContainerController(), tag: 'containerController');
  Get.put(ZoneController(), tag: 'zoneController');
  Get.put(SearchControllerQuery(), tag: 'searchController');
  Get.put(BinController(), tag: 'binController');
  Get.put(DashboardController(), tag: 'dashboardController');
  // Put your new theme controller
  final ThemeController themeController = Get.put(ThemeController());

  // Pass the initial theme to MyApp
  runApp(MyApp(initialTheme: themeController.themeMode));
}

class MyApp extends StatelessWidget {
  // <-- Converted to StatelessWidget
  final ThemeMode initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    HomeService().initialize();

    ///
    return GetMaterialApp(
      theme: Themes().lightTheme,
      darkTheme: Themes().darkTheme,
      themeMode: initialTheme, // <-- Set the initial theme
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      getPages: appRoutes(),
    );
  }
}
