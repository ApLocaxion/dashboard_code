// import 'dart:math';

// import '../../models/scra_bin.dart';

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
