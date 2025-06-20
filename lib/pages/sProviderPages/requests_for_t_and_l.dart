import 'package:brickapp/custom_widgets/notifications_widget.dart';
import 'package:brickapp/models/notification_model.dart';
import 'package:brickapp/providers/notification_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LandAndTruckRequestPage extends ConsumerWidget {
  const LandAndTruckRequestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationList = ref.watch(notificationProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Requests",
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: notificationList.length,
        itemBuilder: (BuildContext context, int index) {
          RequestModel historyModel = notificationList[index];
          return RequestWidget(
            clientName: historyModel.clientName,
            img: historyModel.image,
            itemName: historyModel.itemName,
            itemID: historyModel.itemID,
            time: "${historyModel.time}",
            amount: historyModel.amount,
            phone: historyModel.phone,
          );
        },
      ),
    );
  }
}
