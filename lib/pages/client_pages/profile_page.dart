import 'dart:ui';
import 'package:brickapp/pages/onboardingPages/login.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_images.dart' as backImg;

class ClientProfile extends StatelessWidget {
  const ClientProfile({super.key});
  final double _sigmax = 4.0;
  final double _sigmay = 4.0;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;

    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
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
                  filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
                  child: Container(color: Colors.transparent),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: screenSize / 5),
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
                      const SizedBox(height: 20),
                      Text(
                        "Ramon Hardluck",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "0740856741",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: screenSize / 10),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.clientEditProfilePageRoute,
                              );
                            },
                            leading: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Edit Profile",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize / 20),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.viewFavouritePageRoute,
                              );
                            },
                            leading: Icon(
                              Icons.favorite,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "View Favourites Driver",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.viewFavItemPage,
                              );
                            },
                            leading: Icon(
                              Icons.favorite,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "View Favourites Item",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize / 20),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.lock_outline,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Change Password",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.changePasswordRoute,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize / 20),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (BuildContext context) => LoginPage(),
                                ),
                              );
                            },
                            leading: Icon(
                              Icons.logout_outlined,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Logout",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
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
      ),
    );
  }
}
