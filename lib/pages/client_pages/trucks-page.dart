import 'package:brickapp/custom_widgets/search_field.dart';
import 'package:brickapp/custom_widgets/truck_widget.dart';
import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/pages/client_pages/tuck_detailed.dart';
import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/app_colors.dart';

class TruckPage extends ConsumerWidget {
  TruckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truckDriverList = ref.watch(truckProvider);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Find truck",
            style: GoogleFonts.oxygen(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: SearchCard(hintText: 'Search truck / price'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: truckDriverList.length,
                itemBuilder: (BuildContext context, int index) {
                  TruckDriverModel truckDriverModel = truckDriverList[index];
                  return TruckWidget(
                    name: truckDriverModel.name,
                    truckImg: truckDriverModel.truckImg,
                    profileImg: truckDriverModel.profileImg,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (BuildContext context) =>
                                  TruckDetailed(truck: truckDriverModel),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
