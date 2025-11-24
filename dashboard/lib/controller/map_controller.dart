import 'dart:ui';
import 'package:get/get_rx/get_rx.dart';

class MapController {
  var panPx = Offset(-700, -1200).obs;
  RxDouble zoom = 10.0.obs;
}
