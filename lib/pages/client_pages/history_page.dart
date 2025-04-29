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
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.backImg),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          ListView.builder(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
