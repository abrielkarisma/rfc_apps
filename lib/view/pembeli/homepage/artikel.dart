// import 'package:flutter/material.dart';
// import 'package:rfc_apps/extension/screen_flexible.dart';
// import 'package:rfc_apps/model/artikel.dart';
// import 'package:rfc_apps/service/artikel.dart';
// import 'package:rfc_apps/widget/list_artikel.dart';
// import 'package:shimmer/shimmer.dart';

// class ArtikelScreen extends StatefulWidget {
//   const ArtikelScreen({super.key});

//   @override
//   State<ArtikelScreen> createState() => _ArtikelScreenState();
// }

// class _ArtikelScreenState extends State<ArtikelScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(
//           left: 20, right: 20, top: context.getHeight(100), bottom: 20),
//       width: double.infinity,
//       height: double.infinity,
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             child: Text("Artikel",
//                 style: TextStyle(
//                     fontFamily: "poppins",
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700),
//                 textAlign: TextAlign.start),
//           ),
//           Padding(padding: EdgeInsets.only(top: context.getHeight(59))),
//           Container(
//             width: double.infinity,
//             height: context.getHeight(668),
//             child: FutureBuilder<List<Artikel>>(
//               future: fetchArtikel(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: Shimmer.fromColors(
//                       baseColor: Colors.grey[300]!,
//                       highlightColor: Colors.grey[100]!,
//                       child: Column(
//                         children: [
//                           Container(
//                             margin: EdgeInsets.only(bottom: 24),
//                             width: double.infinity,
//                             height: context.getHeight(118),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(bottom: 24),
//                             width: double.infinity,
//                             height: context.getHeight(118),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(bottom: 24),
//                             width: double.infinity,
//                             height: context.getHeight(120),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(bottom: 24),
//                             width: double.infinity,
//                             height: context.getHeight(118),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(bottom: 24),
//                             width: double.infinity,
//                             height: context.getHeight(118),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No data found'));
//                 } else {
//                   List<Artikel> items = snapshot.data!;
//                   return ListArtikel(aritikels: items);
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
