import 'package:dashboard/service/bin_service.dart';
import 'package:dashboard/service/container_api_service.dart';
import 'package:dashboard/service/map_service.dart';
import 'package:dashboard/service/webSocket_service.dart';
import 'package:dashboard/service/zone_service.dart';
import 'package:dashboard/utility/constant.dart';

class HomeService {
  //

  initialize() async {
    /// load map config (pxPerMeter etc.)
    await MapService().loadMapConfig();

    /// get all forklift last location database
    await ContainerService().getAllForklift();

    /// get all bin's location , status , zone
    await BinService().getAllBin();

    ///  forlift live location from webScoket
    WebsocketService().connectWebSocket(Constants.webSocketUrl);

    /// get all zone's (for search)
    await ZoneService().getAllZone();

    // get zone events
    await ZoneService().getAllzoneEvents();
  }
}
