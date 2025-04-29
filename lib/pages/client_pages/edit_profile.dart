import 'dart:ui';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_images.dart' as backImg;

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});
  final bool isSuccess = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.bottomNavColor,
            centerTitle: true,
            title: Text(
              "Edit Profile",
              style: GoogleFonts.actor(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor,
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backImg.AppImages.backImg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(color: Colors.transparent),
                ),
              ),
              SingleChildScrollView(
                primary: true,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize / 10),
                    Container(
                      alignment: Alignment.topCenter,
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.deepOrange,
                        backgroundImage: NetworkImage(
                          "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize / 5),
                    Container(
                      height: 60,
                      width: screenSize,
                      child: InkWell(
                        onTap: () {},
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Change Photo",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize / 10),
                    Text(
                      "Change Name",
                      style: GoogleFonts.actor(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextColor,
                      ),
                    ),
                    SizedBox(height: screenSize / 30),
                    Container(
                      height: 50,
                      child: TextField(
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBg,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(20.0),
                          filled: true,
                          fillColor: HexColor("FFFFFF").withOpacity(0.5),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: HexColor("FFFFFF").withOpacity(0.6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: HexColor("FFFFFF").withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize / 20),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: MaterialButton(
                        onPressed: () {
                          final snackBar = SnackBar(
                            elevation: 0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.transparent,
                            content: Container(
                              padding: EdgeInsets.all(8.0),
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    isSuccess
                                        ? AppColors.iconColor.withOpacity(0.4)
                                        : AppColors.darkBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child:
                                        isSuccess
                                            ? Text(
                                              "Success!!",
                                              style: GoogleFonts.actor(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Text(
                                              "Warning!!",
                                              style: GoogleFonts.actor(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),
                                            ),
                                  ),
                                  Container(
                                    child:
                                        isSuccess
                                            ? Text(
                                              "Saved successfully",
                                              style: GoogleFonts.actor(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Text(
                                              "Failed to Save",
                                              style: GoogleFonts.actor(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(snackBar);
                          isSuccess ? Navigator.pop(context) : null;
                        },
                        padding: EdgeInsets.all(4.0),
                        height: 40,
                        minWidth: 100,
                        color: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.actor(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightTextColor,
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
      ),
    );
  }
}
