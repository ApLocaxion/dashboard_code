// ignore_for_file: prefer_const_constructors

import 'package:dashboard/pages/dashboard/dashboard.dart';
import 'package:dashboard/pages/home.dart';
import 'package:dashboard/pages/map_view/area_view.dart';
import 'package:dashboard/pages/scan/loaded_view.dart';
import 'package:dashboard/pages/scan/scan.dart';
import 'package:dashboard/pages/scan/search/search.dart';
import 'package:dashboard/pages/simulate/simulate.dart';
import 'package:dashboard/pages/table/table.dart';
import 'package:get/get.dart';

appRoutes() => [
  GetPage(name: "/home", page: () => const Home()),
  GetPage(name: "/areaView", page: () => const AreaMapView()),
  GetPage(name: "/simulate", page: () => const SimulateView()),
  GetPage(name: "/scan", page: () => const ScanPage()),
  GetPage(name: "/dashboard", page: () => const TableWid()),
  GetPage(name: "/searchScreen", page: () => const SearchScreen()),
  GetPage(name: "/load", page: () => const LoadedView()),
  // GetPage(
  //   name: '/editDeviceDetails',
  //   page: () => EditDeviceDetailsPage(mode: '', title: ''),
  // ),
];
