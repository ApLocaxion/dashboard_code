// class AreaMapConfig {
//   final String imageUrl; // background plan image
//   final String? svgUrl; // optional vector plan
//   final double width; // image intrinsic width in px
//   final double height; // image intrinsic height in px
//   final double originX; // world X at image left
//   final double originY; // world Y at image bottom
//   final double scaleX; // px per world unit
//   final double scaleY; // px per world unit
//   final double zoomStep; // per wheel-step zoom increment
//   final double? minZoom;
//   final double? maxZoom;

//   AreaMapConfig({
//     required this.imageUrl,
//     this.svgUrl = 'assets/area-plan-arconic.svg',
//     required this.width,
//     required this.height,
//     this.originX = 0.0,
//     this.originY = 0.0,
//     this.scaleX = 5,
//     this.scaleY = 5,
//     this.zoomStep = 0.1,
//     this.minZoom,
//     this.maxZoom,
//   });

//   /// Factory constructor for JSON parsing
//   factory AreaMapConfig.fromJson(Map<String, dynamic> json) {
//     return AreaMapConfig(
//       imageUrl: json['imageUrl'] as String,
//       svgUrl: json['svgUrl'] as String?,
//       width: (json['width'] as num).toDouble(),
//       height: (json['height'] as num).toDouble(),
//       originX: (json['originX'] ?? 0).toDouble(),
//       originY: (json['originY'] ?? 0).toDouble(),
//       scaleX: (json['scaleX'] ?? 1).toDouble(),
//       scaleY: (json['scaleY'] ?? 1).toDouble(),
//       zoomStep: (json['zoomStep'] ?? 0.01).toDouble(),
//       minZoom: json['minZoom'] != null
//           ? (json['minZoom'] as num).toDouble()
//           : null,
//       maxZoom: json['maxZoom'] != null
//           ? (json['maxZoom'] as num).toDouble()
//           : null,
//     );
//   }

//   /// Convert instance back to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'imageUrl': imageUrl,
//       'svgUrl': svgUrl,
//       'width': width,
//       'height': height,
//       'originX': originX,
//       'originY': originY,
//       'scaleX': scaleX,
//       'scaleY': scaleY,
//       'zoomStep': zoomStep,
//       'minZoom': minZoom,
//       'maxZoom': maxZoom,
//     };
//   }
// }
