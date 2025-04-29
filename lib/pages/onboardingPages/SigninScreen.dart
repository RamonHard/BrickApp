// import 'package:brickapp/providers/view_more_product_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import '../../controllers/destination_controller.dart';

// class SigninScreenState extends ConsumerWidget {
//   final TabController tabController;

//   SigninScreenState({Key? key, required this.tabController}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final moreProductVieList = ref.watch(viewMoreProductProvider);
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 280,
//             child: Stack(
//               children: [
//                 Obx(() {
//                   return Hero(
//                     tag: 'click',
//                     transitionOnUserGestures: true,
//                     child: Container(
//                       width: double.infinity,
//                       height: 250,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(25),
//                         bottomRight: Radius.circular(25),
//                       )),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(25),
//                           bottomRight: Radius.circular(25),
//                         ),
//                         child: Image.asset(
//                           destinationControlller.selectedDestination!.img,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//                 IconButton(
//                   onPressed: () {
//                     tabController.animateTo(1);
//                   },
//                   icon: Icon(
//                     Icons.arrow_circle_left_rounded,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Positioned(
//                   top: 230.0,
//                   right: 0.0,
//                   left: 200,
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     child: FloatingActionButton(
//                       backgroundColor: Colors.white,
//                       onPressed: () {},
//                       elevation: 4,
//                       child: Icon(
//                         Icons.favorite,
//                         color: Color.fromARGB(255, 100, 100, 100),
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               "${destinationControlller.selectedDestination!.destinationTitle} Tour",
//               style: GoogleFonts.actor(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
