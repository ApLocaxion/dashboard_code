// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math';

// void main() {
//   runApp(const ForkliftApp());
// }

// // -----------------------------------------------------------------------------
// // 1. DESIGN SYSTEM & CONSTANTS
// // -----------------------------------------------------------------------------

// class AppColors {
//   static const background = Color(0xFFF5F5F7);
//   static const primaryBlue = Color(0xFF007AFF);
//   static const dangerRed = Color(0xFFFF3B30);
//   static const successGreen = Color(0xFF34C759);
//   static const warningOrange = Color(0xFFFF9500); // Added for fill indicator
//   static const cardBackground = Colors.white;
//   static const textPrimary = Color(0xFF000000);
//   static const textSecondary = Color(0xFF86868B);
//   static const border = Color(0xFFE5E5EA);
//   static const inputBackground = Color(0xFFF2F2F7);

//   static const headerBackground = Color(0xFF000000);
// }

// class AppStyles {
//   static const BorderRadius radius24 = BorderRadius.all(Radius.circular(24));
//   static const BorderRadius radius16 = BorderRadius.all(Radius.circular(16));

//   static const List<BoxShadow> cardShadow = [
//     BoxShadow(
//       color: Color(0x0D000000),
//       blurRadius: 24,
//       offset: Offset(0, 8),
//       spreadRadius: 0,
//     ),
//   ];

//   static const TextStyle headerBrand = TextStyle(
//     fontFamily: 'Arial',
//     fontSize: 24,
//     fontWeight: FontWeight.w900,
//     letterSpacing: -0.5,
//     color: Colors.white,
//   );

//   static const TextStyle headerLabel = TextStyle(
//     fontSize: 10,
//     fontWeight: FontWeight.w800,
//     letterSpacing: 0.5,
//     color: Color(0xFF8E8E93),
//   );

//   static const TextStyle metricLabel = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w900,
//     letterSpacing: 0.8,
//     color: Color(0xFF86868B),
//   );

//   static const TextStyle metricValue = TextStyle(
//     fontFamily: 'Arial',
//     fontSize: 36,
//     fontWeight: FontWeight.w900,
//     color: AppColors.textPrimary,
//     letterSpacing: -1.5,
//     height: 1.0,
//   );
// }

// // -----------------------------------------------------------------------------
// // 2. MOCK DATA (UPDATED FOR ALUMINUM INDUSTRY)
// // -----------------------------------------------------------------------------

// class ScrapBin {
//   final String id;
//   final String alloy;
//   final int weightLbs; // Store raw int for calculation
//   final String zone;
//   final String dwellTime;
//   final String origin;
//   final int capacityLbs; // Added for fill indicator

//   ScrapBin({
//     required this.id,
//     required this.alloy,
//     required this.weightLbs,
//     required this.zone,
//     required this.dwellTime,
//     required this.origin,
//     this.capacityLbs = 2500, // Default capacity
//   });

//   // Helpers for display
//   String get weightKg => (weightLbs * 0.453592).round().toString();
//   String get weightLbsStr => weightLbs.toString();
//   double get fillPercentage => (weightLbs / capacityLbs).clamp(0.0, 1.0);

//   // Helper for dwell time sorting (simple parsing for mock)
//   int get dwellMinutes {
//     final parts = dwellTime.split(' ');
//     int total = 0;
//     for (var part in parts) {
//       if (part.endsWith('h')) total += int.parse(part.replaceAll('h', '')) * 60;
//       if (part.endsWith('m')) total += int.parse(part.replaceAll('m', ''));
//     }
//     return total;
//   }
// }

// final List<ScrapBin> mockBins = List.generate(25, (index) {
//   final alloys = [
//     '3003 H14',
//     '5052 H32',
//     '6061 T6',
//     '7075 T6',
//     '2024 T3',
//     '1100',
//     '3004',
//     '5182',
//     '3105',
//     '5083',
//   ];

//   final origins = [
//     'Slitter 04',
//     'Slitter 12',
//     'Tandem Mill 01',
//     'Scalper 03',
//     'Blanking Line 02',
//     'Cold Mill 05',
//     'Finishing 08',
//   ];

//   final rnd = Random(index);
//   final compartment = rnd.nextInt(15) + 1;
//   final row = rnd.nextInt(12) + 1;
//   final side = rnd.nextBool() ? 'L' : 'R';
//   final location = 'C-$compartment-$row-$side';

//   final hours = rnd.nextInt(48);
//   final mins = rnd.nextInt(60);

//   return ScrapBin(
//     id: 'BIN-${400 + index}',
//     alloy: alloys[index % alloys.length],
//     weightLbs: (rnd.nextInt(2400) + 100), // 100 - 2500 lbs
//     zone: location,
//     dwellTime: '${hours}h ${mins}m',
//     origin: origins[index % origins.length],
//   );
// });

// // -----------------------------------------------------------------------------
// // 3. MAIN APP & STATE MANAGEMENT
// // -----------------------------------------------------------------------------

// class ForkliftApp extends StatefulWidget {
//   const ForkliftApp({super.key});

//   @override
//   State<ForkliftApp> createState() => _ForkliftAppState();
// }

// class _ForkliftAppState extends State<ForkliftApp> {
//   String _currentView = 'scan';
//   ScrapBin? _activeBin;

//   final bool _wifiConnected = true;
//   final bool _rtlsActive = true;
//   final double _batteryLevel = 0.82;
//   final bool _scannerReady = true;

//   final String _currentSpeed = "N/A";
//   final String _shiftTime = "N/A";
//   final String _currentZone = "A-12";

//   void _navigateTo(String view, [ScrapBin? bin]) {
//     setState(() {
//       _currentView = view;
//       if (bin != null) _activeBin = bin;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'LocaXion Forklift',
//       theme: ThemeData(
//         platform: TargetPlatform.iOS,
//         scaffoldBackgroundColor: AppColors.background,
//         primaryColor: AppColors.primaryBlue,
//         useMaterial3: true,
//         fontFamily: 'Arial',
//       ),
//       home: Scaffold(
//         body: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: _buildCurrentView(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentView() {
//     switch (_currentView) {
//       case 'scan':
//         return ScanScreen(
//           currentZone: _currentZone,
//           speed: _currentSpeed,
//           shiftTime: _shiftTime,
//           scannerReady: _scannerReady,
//           onScan: (bin) => _navigateTo('confirm', bin),
//           onNavigate: _navigateTo,
//         );
//       case 'confirm':
//         return ConfirmScreen(
//           bin: _activeBin!,
//           currentZone: _currentZone,
//           onConfirm: () => _navigateTo('loaded'),
//           onCancel: () => _navigateTo('scan'),
//         );
//       case 'loaded':
//         return LoadedScreen(
//           bin: _activeBin!,
//           currentZone: _currentZone,
//           onUnload: () {
//             setState(() => _activeBin = null);
//             _navigateTo('scan');
//           },
//         );
//       case 'search':
//         return SearchScreen(
//           onNavigate: _navigateTo,
//           onSelectBin: (bin) => _navigateTo('confirm', bin),
//         );
//       case 'options':
//         return OptionsScreen(onNavigate: _navigateTo);
//       case 'report':
//         return BinReportScreen(onNavigate: _navigateTo);
//       default:
//         return const Center(child: Text("Unknown View"));
//     }
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       decoration: const BoxDecoration(
//         color: AppColors.headerBackground,
//         border: Border(bottom: BorderSide(color: Color(0xFF333333), width: 1)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Row(
//               children: [
//                 const Text('LocaXion', style: AppStyles.headerBrand),
//                 const SizedBox(width: 16),
//                 Container(width: 1, height: 20, color: Colors.white24),
//                 const SizedBox(width: 16),
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('VEHICLE ID', style: AppStyles.headerLabel),
//                     Text(
//                       'FORKLIFT 03',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 15,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const Expanded(flex: 1, child: SizedBox()),
//           Expanded(
//             flex: 1,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 _StatusPill(
//                   icon: CupertinoIcons.wifi,
//                   label: _wifiConnected ? 'On-Line' : 'Offline',
//                   isActive: _wifiConnected,
//                 ),
//                 const SizedBox(width: 12),
//                 _StatusPill(
//                   icon: CupertinoIcons.antenna_radiowaves_left_right,
//                   label: _rtlsActive ? 'RTLS Active' : 'RTLS Down',
//                   isActive: _rtlsActive,
//                   isBlue: true,
//                 ),
//                 const SizedBox(width: 20),
//                 Container(width: 1, height: 24, color: Colors.white24),
//                 const SizedBox(width: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       '${(_batteryLevel * 100).toInt()}%',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                         height: 1.0,
//                       ),
//                     ),
//                     const Text('BATTERY', style: AppStyles.headerLabel),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // 4. REUSABLE COMPONENTS
// // -----------------------------------------------------------------------------

// class ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isPrimary;
//   final bool isDanger;
//   final VoidCallback onTap;

//   const ActionButton({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.isPrimary = false,
//     this.isDanger = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color bgColor = isPrimary
//         ? AppColors.primaryBlue
//         : isDanger
//         ? AppColors.dangerRed
//         : Colors.white;
//     final Color textColor = (isPrimary || isDanger)
//         ? Colors.white
//         : AppColors.primaryBlue;
//     final Color borderColor = (isPrimary || isDanger)
//         ? Colors.transparent
//         : AppColors.border;

//     return Material(
//       color: bgColor,
//       borderRadius: AppStyles.radius24,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: AppStyles.radius24,
//         child: Container(
//           height: 120,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: AppStyles.radius24,
//             border: Border.all(color: borderColor, width: 2),
//             boxShadow: isPrimary || isDanger
//                 ? [
//                     BoxShadow(
//                       color: bgColor.withOpacity(0.3),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ]
//                 : [],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 36, color: textColor),
//               const SizedBox(height: 12),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MetricWidget extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final String unit;

//   const MetricWidget({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.unit = '',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DashboardCard(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 18, color: AppColors.textSecondary),
//               const SizedBox(width: 8),
//               Text(label, style: AppStyles.metricLabel),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.baseline,
//             textBaseline: TextBaseline.alphabetic,
//             children: [
//               Text(value, style: AppStyles.metricValue),
//               if (unit.isNotEmpty) ...[
//                 const SizedBox(width: 4),
//                 Text(
//                   unit,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatusPill extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool isActive;
//   final bool isBlue;

//   const _StatusPill({
//     required this.icon,
//     required this.label,
//     required this.isActive,
//     this.isBlue = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color textColor = isActive ? Colors.white : const Color(0xFFFF8A8A);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: textColor),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: TextStyle(
//               color: textColor,
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ZoneBadge extends StatelessWidget {
//   final String zone;

//   const ZoneBadge({super.key, required this.zone});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: AppStyles.radius24,
//         border: Border.all(color: AppColors.border, width: 1),
//         boxShadow: AppStyles.cardShadow,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const Text(
//                 'VEHICLE ZONE',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w900,
//                   color: AppColors.textSecondary,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               Text(
//                 zone,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w900,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 16),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: AppColors.primaryBlue,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.location_on, color: Colors.white, size: 20),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // 5. SCREENS
// // -----------------------------------------------------------------------------

// class ScanScreen extends StatefulWidget {
//   final String currentZone;
//   final String speed;
//   final String shiftTime;
//   final bool scannerReady;
//   final Function(ScrapBin) onScan;
//   final Function(String) onNavigate;

//   const ScanScreen({
//     super.key,
//     required this.currentZone,
//     required this.speed,
//     required this.shiftTime,
//     required this.scannerReady,
//     required this.onScan,
//     required this.onNavigate,
//   });

//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();

//   void _handleSubmit(String value) {
//     if (value.isEmpty) return;
//     final bin = ScrapBin(
//       id: value.toUpperCase(),
//       alloy: 'Unknown Alloy',
//       weightLbs: 0, // dummy
//       zone: 'N/A',
//       dwellTime: '0h 0m',
//       origin: 'Manual Entry',
//     );
//     widget.onScan(bin);
//     _controller.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: 160,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 flex: 8,
//                 child: DashboardCard(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 0,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Ready to Load',
//                             style: TextStyle(
//                               fontSize: 40,
//                               fontWeight: FontWeight.w900,
//                               color: AppColors.textPrimary,
//                               letterSpacing: -1.5,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.inputBackground,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: const Icon(
//                                   Icons.person,
//                                   color: AppColors.textSecondary,
//                                   size: 24,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'CURRENT OPERATOR',
//                                     style: AppStyles.metricLabel,
//                                   ),
//                                   RichText(
//                                     text: const TextSpan(
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w800,
//                                         color: AppColors.textPrimary,
//                                         fontFamily: 'Arial',
//                                       ),
//                                       children: [
//                                         TextSpan(text: 'Unassigned '),
//                                         TextSpan(
//                                           text: '(Tap to login)',
//                                           style: TextStyle(
//                                             color: AppColors.primaryBlue,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: const EdgeInsets.only(left: 40),
//                         decoration: const BoxDecoration(
//                           border: Border(
//                             left: BorderSide(color: AppColors.border, width: 2),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             const Text(
//                               'CURRENT ZONE',
//                               style: AppStyles.metricLabel,
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const Icon(
//                                   Icons.location_on,
//                                   color: AppColors.primaryBlue,
//                                   size: 30,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   widget.currentZone,
//                                   style: const TextStyle(
//                                     fontSize: 54,
//                                     fontWeight: FontWeight.w900,
//                                     color: AppColors.primaryBlue,
//                                     letterSpacing: -2.0,
//                                     height: 1.0,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 flex: 2,
//                 child: MetricWidget(
//                   icon: CupertinoIcons.speedometer,
//                   label: 'SPEED',
//                   value: widget.speed,
//                 ),
//               ),
//               const SizedBox(width: 24),
//               Expanded(
//                 flex: 2,
//                 child: MetricWidget(
//                   icon: CupertinoIcons.time,
//                   label: 'SHIFT TIME',
//                   value: widget.shiftTime,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 32),

//         Expanded(
//           child: DashboardCard(
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 800),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 24,
//                         horizontal: 32,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.inputBackground,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: const Color(0xFFE0E0E0),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: _controller,
//                         focusNode: _focusNode,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 2.0,
//                           color: AppColors.textPrimary,
//                         ),
//                         textCapitalization: TextCapitalization.characters,
//                         decoration: InputDecoration(
//                           hintText: 'SCAN OR TYPE BIN ID',
//                           hintStyle: TextStyle(
//                             color: AppColors.textSecondary.withOpacity(0.25),
//                             fontSize: 48,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: 1.0,
//                           ),
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                         onSubmitted: _handleSubmit,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: widget.scannerReady
//                                 ? AppColors.successGreen
//                                 : AppColors.dangerRed,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           widget.scannerReady
//                               ? 'SCANNER READY & ACTIVE'
//                               : 'SCANNER DISCONNECTED',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 1.5,
//                             color: widget.scannerReady
//                                 ? AppColors.textSecondary
//                                 : AppColors.dangerRed,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 32),

//         Row(
//           children: [
//             Expanded(
//               child: ActionButton(
//                 icon: CupertinoIcons.keyboard,
//                 label: 'MANUAL ENTRY',
//                 isPrimary: true,
//                 onTap: () {
//                   FocusScope.of(context).requestFocus(_focusNode);
//                   SystemChannels.textInput.invokeMethod('TextInput.show');
//                 },
//               ),
//             ),
//             const SizedBox(width: 32),
//             Expanded(
//               child: ActionButton(
//                 icon: CupertinoIcons.search,
//                 label: 'SEARCH BINS',
//                 onTap: () => widget.onNavigate('search'),
//               ),
//             ),
//             const SizedBox(width: 32),
//             Expanded(
//               child: ActionButton(
//                 icon: CupertinoIcons.square_grid_2x2,
//                 label: 'OPTIONS',
//                 onTap: () => widget.onNavigate('options'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class ConfirmScreen extends StatelessWidget {
//   final ScrapBin bin;
//   final String currentZone;
//   final VoidCallback onConfirm;
//   final VoidCallback onCancel;

//   const ConfirmScreen({
//     super.key,
//     required this.bin,
//     required this.currentZone,
//     required this.onConfirm,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 700),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   const Text(
//                     'ARE YOU LOADING BIN?',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.textSecondary,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     bin.id,
//                     style: const TextStyle(
//                       fontSize: 90,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.primaryBlue,
//                       letterSpacing: -2.5,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   DashboardCard(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 40,
//                       vertical: 32,
//                     ),
//                     child: Column(
//                       children: [
//                         _DetailRow(label: 'ALLOY', value: bin.alloy),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Divider(height: 1, color: AppColors.border),
//                         ),
//                         _DetailRow(
//                           label: 'WEIGHT',
//                           value: '${bin.weightLbs} lbs',
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Divider(height: 1, color: AppColors.border),
//                         ),
//                         _DetailRow(label: 'BIN ZONE', value: bin.zone),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ActionButton(
//                           icon: CupertinoIcons.xmark,
//                           label: 'NO',
//                           isDanger: true,
//                           onTap: onCancel,
//                         ),
//                       ),
//                       const SizedBox(width: 32),
//                       Expanded(
//                         child: ActionButton(
//                           icon: CupertinoIcons.checkmark_alt,
//                           label: 'YES',
//                           isPrimary: true,
//                           onTap: onConfirm,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned(top: 0, right: 0, child: ZoneBadge(zone: currentZone)),
//       ],
//     );
//   }
// }

// class LoadedScreen extends StatelessWidget {
//   final ScrapBin bin;
//   final String currentZone;
//   final VoidCallback onUnload;

//   const LoadedScreen({
//     super.key,
//     required this.bin,
//     required this.currentZone,
//     required this.onUnload,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 700),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 60),
//                   const Text(
//                     'CURRENT LOAD',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.textSecondary,
//                       letterSpacing: 2.0,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     bin.id,
//                     style: const TextStyle(
//                       fontSize: 96,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.primaryBlue,
//                       letterSpacing: -3.0,
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       DashboardCard(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 32,
//                         ),
//                         child: Column(
//                           children: [
//                             _DetailRow(label: 'ALLOY', value: bin.alloy),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Divider(
//                                 height: 1,
//                                 color: AppColors.border,
//                               ),
//                             ),
//                             _DetailRow(
//                               label: 'WEIGHT',
//                               value: '${bin.weightLbs} lbs',
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Divider(
//                                 height: 1,
//                                 color: AppColors.border,
//                               ),
//                             ),
//                             _DetailRow(label: 'BIN ZONE', value: bin.zone),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         top: -16,
//                         left: -16,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.successGreen,
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(24),
//                               bottomRight: Radius.circular(24),
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 12,
//                                 offset: const Offset(4, 4),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'LOADED',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 60),

//                   ActionButton(
//                     icon: Icons.logout,
//                     label: 'UNLOAD BIN',
//                     isDanger: true,
//                     onTap: onUnload,
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Positioned(top: 0, right: 0, child: ZoneBadge(zone: currentZone)),
//       ],
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 160,
//           child: Text(
//             label,
//             style: AppStyles.metricLabel.copyWith(fontSize: 14),
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w900,
//             color: AppColors.textPrimary,
//             letterSpacing: -0.5,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class SearchScreen extends StatefulWidget {
//   final Function(String) onNavigate;
//   final Function(ScrapBin) onSelectBin;

//   const SearchScreen({
//     super.key,
//     required this.onNavigate,
//     required this.onSelectBin,
//   });

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   ScrapBin? _selectedBin;
//   String _searchQuery = "";

//   List<ScrapBin> get _filteredBins {
//     if (_searchQuery.isEmpty) return mockBins;
//     return mockBins
//         .where(
//           (b) => b.id.contains(_searchQuery) || b.alloy.contains(_searchQuery),
//         )
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             InkWell(
//               onTap: () => widget.onNavigate('scan'),
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 24),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.search, color: AppColors.textSecondary),
//                     const SizedBox(width: 24),
//                     Expanded(
//                       child: TextField(
//                         onChanged: (val) =>
//                             setState(() => _searchQuery = val.toUpperCase()),
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary,
//                         ),
//                         decoration: const InputDecoration(
//                           hintText: 'SEARCH BY BIN ID OR ALLOY GRADE...',
//                           border: InputBorder.none,
//                           hintStyle: TextStyle(color: Color(0xFFC7C7CC)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 32),
//         Expanded(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Expanded(
//                 flex: 4,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     border: Border(right: BorderSide(color: AppColors.border)),
//                   ),
//                   child: ListView.separated(
//                     padding: const EdgeInsets.only(right: 24),
//                     itemCount: _filteredBins.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 16),
//                     itemBuilder: (context, index) {
//                       final bin = _filteredBins[index];
//                       final isSelected = _selectedBin?.id == bin.id;
//                       return DashboardCard(
//                         onTap: () => setState(() => _selectedBin = bin),
//                         borderColor: isSelected ? AppColors.primaryBlue : null,
//                         backgroundColor: isSelected
//                             ? const Color(0xFFF0F8FF)
//                             : Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 16,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   bin.id,
//                                   style: TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w900,
//                                     color: isSelected
//                                         ? AppColors.primaryBlue
//                                         : AppColors.textPrimary,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   bin.alloy,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColors.textSecondary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 const Text(
//                                   'WEIGHT',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.textSecondary,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${bin.weightLbs} lbs',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 32),
//               Expanded(
//                 flex: 8,
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF2F2F7),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: _selectedBin == null
//                       ? const Center(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.touch_app,
//                                 size: 80,
//                                 color: Color(0xFFD1D1D6),
//                               ),
//                               SizedBox(height: 24),
//                               Text(
//                                 'Select a bin to view details',
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   color: AppColors.textSecondary,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             // UPDATED: Reduced size/padding of details card
//                             DashboardCard(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 16,
//                                 horizontal: 24,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     _selectedBin!.id,
//                                     style: const TextStyle(
//                                       fontSize: 48, // Slightly smaller
//                                       fontWeight: FontWeight.w900,
//                                       color: AppColors.primaryBlue,
//                                       letterSpacing: -1.5,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   _DetailRow(
//                                     label: 'GRADE',
//                                     value: _selectedBin!.alloy,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   _DetailRow(
//                                     label: 'WEIGHT',
//                                     value: '${_selectedBin!.weightLbs} lbs',
//                                   ),
//                                   const SizedBox(height: 8),
//                                   _DetailRow(
//                                     label: 'LOCATION',
//                                     value: _selectedBin!.zone,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             Expanded(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(24),
//                                   border: Border.all(color: AppColors.border),
//                                 ),
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFE5ECF6),
//                                         borderRadius: BorderRadius.circular(24),
//                                       ),
//                                       child: const Center(
//                                         child: Icon(
//                                           Icons.map,
//                                           size: 100,
//                                           color: Color(0xFFD1D1D6),
//                                         ),
//                                       ),
//                                     ),
//                                     const Positioned(
//                                       top: 24,
//                                       left: 24,
//                                       child: Card(
//                                         child: Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 8,
//                                           ),
//                                           child: Text(
//                                             "MAP VIEW",
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             SizedBox(
//                               height: 90,
//                               child: ElevatedButton(
//                                 onPressed: () =>
//                                     widget.onSelectBin(_selectedBin!),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primaryBlue,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 child: const Text(
//                                   'LOAD THIS BIN',
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.w900,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class OptionsScreen extends StatelessWidget {
//   final Function(String) onNavigate;

//   const OptionsScreen({super.key, required this.onNavigate});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Row(
//           children: [
//             InkWell(
//               onTap: () => onNavigate('scan'),
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 24),
//             const Text(
//               'Options',
//               style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
//             ),
//           ],
//         ),
//         const SizedBox(height: 40),
//         Expanded(
//           child: GridView.count(
//             crossAxisCount: 3,
//             mainAxisSpacing: 32,
//             crossAxisSpacing: 32,
//             childAspectRatio: 2.2,
//             children: [
//               DashboardCard(
//                 onTap: () {},
//                 child: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.person, size: 56, color: AppColors.primaryBlue),
//                     SizedBox(height: 20),
//                     Text(
//                       'Driver Login',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               DashboardCard(
//                 onTap: () {},
//                 child: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.local_shipping,
//                       size: 56,
//                       color: AppColors.primaryBlue,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Vehicle Check',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               DashboardCard(
//                 onTap: () => onNavigate('report'),
//                 child: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.assessment,
//                       size: 56,
//                       color: AppColors.primaryBlue,
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Bin Report',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 32),
//         ActionButton(icon: Icons.logout, label: 'LOG OUT SYSTEM', onTap: () {}),
//       ],
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // 6. BIN REPORT SCREEN (ENHANCED)
// // -----------------------------------------------------------------------------

// class BinReportScreen extends StatefulWidget {
//   final Function(String) onNavigate;

//   const BinReportScreen({super.key, required this.onNavigate});

//   @override
//   State<BinReportScreen> createState() => _BinReportScreenState();
// }

// class _BinReportScreenState extends State<BinReportScreen> {
//   bool _showKg = false;
//   String _searchQuery = "";
//   int _sortColumnIndex = 0;
//   bool _isAscending = true;
//   List<String> _activeFilters = [];

//   final List<String> _filterOptions = [
//     '> 24h Dwell',
//     'Heavy (>2k lbs)',
//     'Empty',
//   ];

//   // Filter and Sort bins
//   List<ScrapBin> get _filteredBins {
//     List<ScrapBin> list;
//     if (_searchQuery.isEmpty && _activeFilters.isEmpty) {
//       list = List.from(mockBins);
//     } else {
//       list = mockBins.where((bin) {
//         bool matchesSearch =
//             bin.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             bin.alloy.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//             bin.zone.toLowerCase().contains(_searchQuery.toLowerCase());

//         bool matchesFilters = true;
//         if (_activeFilters.contains('> 24h Dwell')) {
//           matchesFilters = matchesFilters && bin.dwellMinutes > 24 * 60;
//         }
//         if (_activeFilters.contains('Heavy (>2k lbs)')) {
//           matchesFilters = matchesFilters && bin.weightLbs > 2000;
//         }
//         if (_activeFilters.contains('Empty')) {
//           matchesFilters = matchesFilters && bin.weightLbs == 0;
//         }

//         return matchesSearch && matchesFilters;
//       }).toList();
//     }

//     // Sorting Logic
//     list.sort((a, b) {
//       int compareResult;
//       switch (_sortColumnIndex) {
//         case 0: // Bin ID
//           compareResult = a.id.compareTo(b.id);
//           break;
//         case 1: // Alloy
//           compareResult = a.alloy.compareTo(b.alloy);
//           break;
//         case 2: // Weight
//           compareResult = a.weightLbs.compareTo(b.weightLbs);
//           break;
//         case 4: // Dwell Time
//           compareResult = a.dwellMinutes.compareTo(b.dwellMinutes);
//           break;
//         default:
//           compareResult = 0;
//       }
//       return _isAscending ? compareResult : -compareResult;
//     });

//     return list;
//   }

//   void _onSort(int columnIndex) {
//     if (_sortColumnIndex == columnIndex) {
//       setState(() {
//         _isAscending = !_isAscending;
//       });
//     } else {
//       setState(() {
//         _sortColumnIndex = columnIndex;
//         _isAscending = true;
//       });
//     }
//   }

//   void _toggleFilter(String filter) {
//     setState(() {
//       if (_activeFilters.contains(filter)) {
//         _activeFilters.remove(filter);
//       } else {
//         _activeFilters.add(filter);
//       }
//     });
//   }

//   void _showInspector(ScrapBin bin) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: 400,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Bin Inspector: ${bin.id}',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 _InspectorDetail('Alloy', bin.alloy),
//                 const SizedBox(width: 32),
//                 _InspectorDetail('Current Weight', '${bin.weightLbs} lbs'),
//                 const SizedBox(width: 32),
//                 _InspectorDetail(
//                   'Fill Level',
//                   '${(bin.fillPercentage * 100).toInt()}%',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             const Text('RECENT HISTORY', style: AppStyles.metricLabel),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _HistoryItem(
//                     time: '10:30 AM',
//                     event: 'Moved to ${bin.zone}',
//                     user: 'Forklift 03',
//                   ),
//                   _HistoryItem(
//                     time: '08:15 AM',
//                     event: 'Created at ${bin.origin}',
//                     user: 'System',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Header Row
//         Row(
//           children: [
//             InkWell(
//               onTap: () => widget.onNavigate('options'),
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 24),
//             const Text(
//               'Bin Inventory Report',
//               style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
//             ),
//             const Spacer(),
//             // Export Button (New)
//             IconButton(
//               onPressed: () {
//                 /* Export Logic */
//               },
//               icon: const Icon(
//                 Icons.share,
//                 color: AppColors.primaryBlue,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Search Bar
//             Container(
//               width: 300,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.search, color: AppColors.textSecondary),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextField(
//                       onChanged: (val) => setState(() => _searchQuery = val),
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                       decoration: const InputDecoration(
//                         hintText: 'Search Report...',
//                         border: InputBorder.none,
//                         hintStyle: TextStyle(color: Color(0xFFC7C7CC)),
//                         contentPadding: EdgeInsets.only(bottom: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Unit Toggle Button
//             Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE5E5EA),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(4),
//               child: Row(
//                 children: [
//                   _UnitToggleOption(
//                     label: 'LBS',
//                     isSelected: !_showKg,
//                     onTap: () => setState(() => _showKg = false),
//                   ),
//                   _UnitToggleOption(
//                     label: 'KG',
//                     isSelected: _showKg,
//                     onTap: () => setState(() => _showKg = true),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // Filter Chips Row (New)
//         Row(
//           children: [
//             const Text(
//               'Quick Filters:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Wrap(
//               spacing: 8,
//               children: _filterOptions.map((filter) {
//                 final isSelected = _activeFilters.contains(filter);
//                 return FilterChip(
//                   label: Text(filter),
//                   selected: isSelected,
//                   onSelected: (_) => _toggleFilter(filter),
//                   backgroundColor: Colors.white,
//                   selectedColor: AppColors.primaryBlue.withOpacity(0.2),
//                   labelStyle: TextStyle(
//                     color: isSelected
//                         ? AppColors.primaryBlue
//                         : AppColors.textPrimary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     side: BorderSide(
//                       color: isSelected
//                           ? AppColors.primaryBlue
//                           : AppColors.border,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),

//         const SizedBox(height: 24),

//         // Summary Metrics Row
//         Row(
//           children: [
//             _SummaryCard(
//               label: 'TOTAL BINS',
//               value: '${_filteredBins.length}',
//               icon: Icons.inventory_2_outlined,
//             ),
//             const SizedBox(width: 16),
//             _SummaryCard(
//               label: 'TOTAL WEIGHT',
//               value: _calculateTotalWeight(),
//               icon: Icons.scale_outlined,
//             ),
//             const SizedBox(width: 16),
//             _SummaryCard(
//               label: 'AVG DWELL TIME',
//               value: '3h 12m',
//               icon: Icons.timer_outlined,
//             ),
//           ],
//         ),

//         const SizedBox(height: 24),

//         // Report Table Container
//         Expanded(
//           child: DashboardCard(
//             padding: const EdgeInsets.all(0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: Column(
//                 children: [
//                   // Table Header with Sort
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 24,
//                     ),
//                     color: const Color(0xFFF9FAFB),
//                     child: Row(
//                       children: [
//                         _buildSortableHeader('BIN ID', 0, flex: 2),
//                         _buildSortableHeader('ALLOY GRADE', 1, flex: 3),
//                         _buildSortableHeader(
//                           'WEIGHT (${_showKg ? 'KG' : 'LBS'})',
//                           2,
//                           flex: 2,
//                         ),
//                         _buildHeaderCell(
//                           'LOCATION',
//                           flex: 3,
//                         ), // Not sortable for now
//                         _buildSortableHeader('DWELL TIME', 4, flex: 2),
//                         _buildHeaderCell(
//                           'ORIGIN',
//                           flex: 3,
//                         ), // Not sortable for now
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1, color: AppColors.border),

//                   // Table Body (Scrollable List)
//                   Expanded(
//                     child: ListView.separated(
//                       itemCount: _filteredBins.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 1, color: AppColors.border),
//                       itemBuilder: (context, index) {
//                         final bin = _filteredBins[index];
//                         final weightDisplay = _showKg
//                             ? '${bin.weightKg} kg'
//                             : '${bin.weightLbsStr} lbs';

//                         // Highlight long dwell times
//                         final isLongDwell = bin.dwellMinutes > 24 * 60;

//                         return InkWell(
//                           onTap: () => _showInspector(bin),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 32,
//                               vertical: 16,
//                             ), // Reduced vertical padding
//                             color: index % 2 == 0
//                                 ? Colors.white
//                                 : const Color(0xFFFCFDFF),
//                             child: Row(
//                               children: [
//                                 _buildDataCell(bin.id, flex: 2, isBold: true),
//                                 // Alloy Badge Logic
//                                 Expanded(
//                                   flex: 3,
//                                   child: Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: _AlloyBadge(alloy: bin.alloy),
//                                   ),
//                                 ),
//                                 // Weight with Fill Indicator
//                                 Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         weightDisplay,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w800,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       _FillIndicator(
//                                         percentage: bin.fillPercentage,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 _buildDataCell(bin.zone, flex: 3),
//                                 _buildDataCell(
//                                   bin.dwellTime,
//                                   flex: 2,
//                                   color: isLongDwell
//                                       ? AppColors.dangerRed
//                                       : AppColors.textSecondary,
//                                   isBold: isLongDwell,
//                                 ),
//                                 _buildDataCell(bin.origin, flex: 3),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _calculateTotalWeight() {
//     int totalLbs = _filteredBins.fold(0, (sum, bin) => sum + bin.weightLbs);
//     if (_showKg) {
//       return '${(totalLbs * 0.453592).round()} kg';
//     }
//     return '$totalLbs lbs';
//   }

//   Widget _buildSortableHeader(String text, int index, {required int flex}) {
//     final isSelected = _sortColumnIndex == index;
//     return Expanded(
//       flex: flex,
//       child: InkWell(
//         onTap: () => _onSort(index),
//         child: Row(
//           children: [
//             Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w900,
//                 color: isSelected
//                     ? AppColors.primaryBlue
//                     : AppColors.textSecondary,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             if (isSelected)
//               Icon(
//                 _isAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
//                 color: AppColors.primaryBlue,
//                 size: 18,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderCell(String text, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w900,
//           color: AppColors.textSecondary,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }

//   Widget _buildDataCell(
//     String text, {
//     required int flex,
//     bool isBold = false,
//     Color? color,
//     bool? isBoldOverride,
//   }) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: (isBoldOverride ?? isBold)
//               ? FontWeight.w800
//               : FontWeight.w600,
//           color: color ?? AppColors.textPrimary,
//           letterSpacing: -0.3,
//         ),
//       ),
//     );
//   }
// }

// class _InspectorDetail extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InspectorDetail(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: AppStyles.metricLabel),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }

// class _HistoryItem extends StatelessWidget {
//   final String time;
//   final String event;
//   final String user;

//   const _HistoryItem({
//     required this.time,
//     required this.event,
//     required this.user,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         children: [
//           Text(
//             time,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             child: Text(
//               event,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Text(
//             user,
//             style: const TextStyle(
//               color: AppColors.primaryBlue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FillIndicator extends StatelessWidget {
//   final double percentage;

//   const _FillIndicator({required this.percentage});

//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     if (percentage > 0.95) {
//       color = AppColors.dangerRed;
//     } else if (percentage > 0.80) {
//       color = AppColors.warningOrange;
//     } else {
//       color = AppColors.successGreen;
//     }

//     return Container(
//       height: 4,
//       width: 60,
//       decoration: BoxDecoration(
//         color: AppColors.border,
//         borderRadius: BorderRadius.circular(2),
//       ),
//       alignment: Alignment.centerLeft,
//       child: Container(
//         width: 60 * percentage,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(2),
//         ),
//       ),
//     );
//   }
// }

// // Helper Widget for Alloy Badges
// class _AlloyBadge extends StatelessWidget {
//   final String alloy;

//   const _AlloyBadge({required this.alloy});

//   @override
//   Widget build(BuildContext context) {
//     Color bgColor;
//     Color textColor;

//     if (alloy.startsWith('3')) {
//       // 3xxx Series
//       bgColor = Colors.blue.withOpacity(0.1);
//       textColor = Colors.blue[800]!;
//     } else if (alloy.startsWith('5')) {
//       // 5xxx Series
//       bgColor = Colors.green.withOpacity(0.1);
//       textColor = Colors.green[800]!;
//     } else if (alloy.startsWith('6')) {
//       // 6xxx Series
//       bgColor = Colors.orange.withOpacity(0.1);
//       textColor = Colors.orange[800]!;
//     } else if (alloy.startsWith('7')) {
//       // 7xxx Series
//       bgColor = Colors.purple.withOpacity(0.1);
//       textColor = Colors.purple[800]!;
//     } else {
//       bgColor = Colors.grey.withOpacity(0.1);
//       textColor = Colors.grey[800]!;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         alloy,
//         style: TextStyle(
//           color: textColor,
//           fontWeight: FontWeight.w700,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

// class _SummaryCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;

//   const _SummaryCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.border),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0x08000000),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: AppColors.textSecondary, size: 24),
//             ),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.textSecondary,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                     color: AppColors.textPrimary,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _UnitToggleOption extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _UnitToggleOption({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w800,
//             color: isSelected ? Colors.black : const Color(0xFF8E8E93),
//           ),
//         ),
//       ),
//     );
//   }
// }
