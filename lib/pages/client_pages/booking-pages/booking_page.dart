import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../utils/app_colors.dart';

class BookingPage extends ConsumerWidget {
  BookingPage({super.key, required this.selectedItem});
  final ProductModel selectedItem;
  final TextStyle darkTextStyle = GoogleFonts.actor(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.darkTextColor,
  );
  final TextStyle orangeTextStyle = GoogleFonts.actor(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.orangeTextColor,
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
        centerTitle: true,
        title: Text(
          "Booking",
          style: GoogleFonts.actor(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 150,
                width: deviceSize,
                child: Image.network(
                  selectedItem.productIMG,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: deviceSize / 30),
            Container(
              padding: EdgeInsets.all(8.0),
              width: deviceSize,
              decoration: BoxDecoration(
                color: HexColor("AEB6BF"),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: HexColor("FFFFFF"),
                    ),
                    width: deviceSize,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                          child: Text(
                            "Details",
                            style: GoogleFonts.actor(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkTextColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            bottom: 4.0,
                          ),
                          child: Row(
                            children: [
                              Text("Item ID: ", style: darkTextStyle),
                              Text(
                                "${selectedItem.id}",
                                style: orangeTextStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            bottom: 4.0,
                          ),
                          child: Row(
                            children: [
                              Text("Item Price: ", style: darkTextStyle),
                              Text(
                                "${selectedItem.price}",
                                style: orangeTextStyle,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            bottom: 4.0,
                          ),
                          child: Row(
                            children: [
                              Text("Location: ", style: darkTextStyle),
                              Text(
                                "${selectedItem.location}",
                                style: orangeTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: deviceSize / 20),
                  Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: deviceSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {},
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://seeklogo.com/images/A/airtel-logo-593C498F73-seeklogo.com.png",
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        "Pay Using Airtel",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: deviceSize / 20),
                  Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: deviceSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {},
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://upload.wikimedia.org/wikipedia/commons/9/93/New-mtn-logo.jpg",
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        "Pay Using MTN",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: deviceSize / 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      height: 40,
                      minWidth: deviceSize,
                      onPressed: () {
                        MainNavigation.navigateToRoute(
                          MainNavigation.truckPageRoute,
                        );
                      },
                      color: AppColors.iconColor,
                      child: Text(
                        "Find Your Transporter Here",
                        style: GoogleFonts.actor(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
