// import 'package:brickapp/utils/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:intl/intl.dart';

// class Message {
//   final DateTime timestamp;

//   Message({required this.timestamp});
// }

// class MessageWidget extends StatelessWidget {
//   final Message message;

//   MessageWidget(
//       {required this.message,
//       required this.clientName,
//       required this.itemName,
//       required this.itemID,
//       required this.amount,
//       required this.img});
//   final String img;
//   final String clientName;
//   final String itemName;
//   final int itemID;
//   final double amount;

//   @override
//   Widget build(BuildContext context) {
//     DateTime now = DateTime.now();
//     DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
//     DateTime lastWeek = DateTime(now.year, now.month, now.day - 7);

//     String formattedTime = '';

//     if (message.timestamp.year == now.year &&
//         message.timestamp.month == now.month &&
//         message.timestamp.day == now.day) {
//       // Today
//       formattedTime = DateFormat.Hm().format(message.timestamp);
//     } else if (message.timestamp.year == yesterday.year &&
//         message.timestamp.month == yesterday.month &&
//         message.timestamp.day == yesterday.day) {
//       // Yesterday
//       formattedTime = 'Yesterday';
//     } else if (message.timestamp.isAfter(lastWeek)) {
//       // Within the last week
//       formattedTime = DateFormat.E().format(message.timestamp);
//     } else {
//       // Older than a week
//       formattedTime = DateFormat.yMd().format(message.timestamp);
//     }

//     return Padding(
//       padding: const EdgeInsets.all(2.0),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [AppColors.lightTextColor, AppColors.backgroundColor]),
//           border: Border(
//             bottom: BorderSide(color: AppColors.darkBg, width: 2),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "From Me:",
//                 style: GoogleFonts.actor(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.darkTextColor),
//               ),
//               ListTile(
//                 leading: CircleAvatar(
//                   radius: 35,
//                   backgroundImage: NetworkImage(img),
//                 ),
//                 title: Text(
//                   clientName,
//                   style: GoogleFonts.acme(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.darkTextColor),
//                 ),
//               ),
//               Text(
//                 "Booked: ${itemName}",
//                 style: GoogleFonts.acme(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.darkTextColor),
//               ),
//               Text(
//                 "$formattedTime",
//                 style: GoogleFonts.acme(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.darkTextColor),
//               ),
//               Text(
//                 "Amount:\$ ${amount}",
//                 style: GoogleFonts.acme(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.darkTextColor),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
