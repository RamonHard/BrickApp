import 'package:brickapp/models/destination_model.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingPageForMore extends ConsumerWidget {
  BookingPageForMore({super.key, required this.selectedItem});
  final MoreProductViewModel selectedItem;
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
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: HexColor("FFFFFF"),
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
        backgroundColor: HexColor("FFFFFF"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 150,
                width: deviceWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                    image: NetworkImage(selectedItem.img),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: deviceWidth / 30),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: deviceWidth,
                decoration: BoxDecoration(
                  color: HexColor("ECECEC"),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: HexColor("FFFFFF"),
                      ),
                      width: deviceWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 4.0,
                            ),
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
                    SizedBox(height: deviceWidth / 20),
                    Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: deviceWidth,
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
                    SizedBox(height: deviceWidth / 20),
                    Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: deviceWidth,
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
                    SizedBox(height: deviceWidth / 30),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        height: 40,
                        minWidth: deviceWidth,
                        onPressed: () {},
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
            ),
          ],
        ),
      ),
    );
  }
}
