import 'dart:ui';
import 'package:brickapp/models/destination_model.dart';
import 'package:brickapp/providers/house_view_provider.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/house_views_model.dart';
import '../../utils/app_colors.dart';
import 'full_screen_view.dart';

class DetailedHouseView extends ConsumerWidget {
  DetailedHouseView({
    super.key,
    required this.houseIMG,
    required this.id,
    required this.location,
    required this.description,
    required this.price,
    required this.contact,
    required this.selectedProduct,
  });
  final String houseIMG;
  final int id;
  final String location;
  final String description;
  final int contact;
  final double price;
  final MoreProductViewModel selectedProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final houseViewImageList = ref.watch(houseViewProvider);

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
        ),
        body: SingleChildScrollView(
          primary: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      child: Container(
                        height: height * 1 / 2.5,
                        width: width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(houseIMG),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      height: 50,
                      child: ListTile(
                        leading: Text(
                          "Rent now",
                          style: GoogleFonts.actor(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.iconColor,
                          ),
                        ),
                        trailing: MaterialButton(
                          onPressed: () {
                            MainNavigation.navigateToRoute(
                              MainNavigation.bookingPageForMoreRoute,
                              data: selectedProduct,
                            );
                          },
                          padding: EdgeInsets.all(4.0),
                          height: 40,
                          minWidth: 100,
                          color: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "Book",
                            style: GoogleFonts.actor(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Text(
                  "Location:",
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                title: Text(
                  location,
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                trailing: MaterialButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (BuildContext context) => MapScreen(),
                    //   ),
                    // );
                  },
                  color: AppColors.iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "View Location",
                    style: GoogleFonts.actor(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Text(
                  "House Number:",
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                title: Text(
                  "${id}",
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
              ),
              ListTile(
                leading: Text(
                  "Price:",
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
                title: Text(
                  "UGX ${price}",
                  style: GoogleFonts.actor(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.iconColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  description,
                  maxLines: 5,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.actor(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Featured Images",
                  style: GoogleFonts.actor(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: HexColor("000000"),
                  ),
                ),
              ),
              Container(
                height: 220,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: houseViewImageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    HouseViewsModel houseViewsModel = houseViewImageList[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FullScreenView(
                                    imageUrl: houseViewsModel.insideView,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          width: 200,
                          child: Image.network(
                            houseViewsModel.insideView as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: height * 1 / 20),
            ],
          ),
        ),
      ),
    );
  }
}
