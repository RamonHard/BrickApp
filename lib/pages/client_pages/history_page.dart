import 'dart:ui';
import 'package:brickapp/custom_widgets/client_request_widet.dart';
import 'package:brickapp/models/client_requests_model.dart';
import 'package:brickapp/providers/notification_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ClientHistoryPage extends ConsumerWidget {
  const ClientHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final clietnRequestList = ref.watch(clietntReqestProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBG,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.iconColor.withOpacity(0.1),
              Colors.grey.shade100,
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: clietnRequestList.length,
          itemBuilder: (BuildContext context, int index) {
            ClientHistoryModel clientRequestsModel = clietnRequestList[index];
            return ClientHistoryWidget(
              img: clientRequestsModel.image,
              clientName: clientRequestsModel.clientName,
              itemName: clientRequestsModel.itemName,
              itemID: clientRequestsModel.itemID,
              time: "${clientRequestsModel.time}",
              amount: clientRequestsModel.amount,
              transactionType: clientRequestsModel.transactionType,
              duration: clientRequestsModel.duration,
              paymentMethod: clientRequestsModel.paymentMethod,
              transactionDate: DateTime.parse(
                clientRequestsModel.transactionDate.toString(),
              ),
              dueDate: clientRequestsModel.dueDate,
              depositAmount: clientRequestsModel.depositAmount,
              taxAmount: clientRequestsModel.taxAmount,
              transactionId: clientRequestsModel.transactionId,
            );
          },
        ),
      ),
    );
  }
}
