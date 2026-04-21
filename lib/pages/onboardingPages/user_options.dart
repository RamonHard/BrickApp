import 'dart:ui';
import 'package:brickapp/pages/onboardingPages/register_property_manager.dart';
import 'package:brickapp/pages/onboardingPages/sign_up.dart';
import 'package:brickapp/providers/account_type_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_images.dart' as appImg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserOnboardOptions extends ConsumerWidget {
  const UserOnboardOptions({super.key});
  final double _sigmax = 2.0;
  final double _sigmay = 2.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = MediaQuery.of(context).size.width;

    return Scaffold(
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
      body: Stack(
        alignment: Alignment.topCenter,
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
              filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
              child: Container(color: Colors.transparent),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    // Set account type and navigate

                    MainNavigation.navigateToRoute(
                      MainNavigation.register_truckerDriverRoute,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: deviceSize,
                        child: Card(
                          child: Image.asset(
                            'images/serviceProvider.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 150,
                        width: deviceSize,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Text(
                        "Am a Transport Service Provider",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: deviceSize / 10),
                InkWell(
                  onTap: () {
                    // Set account type and navigate

                    MainNavigation.navigateToRoute(
                      MainNavigation.register_addpostRoute,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: deviceSize,
                        child: Card(
                          child: Image.asset(
                            'images/propertyManager.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 150,
                        width: deviceSize,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      Text(
                        "Am a Property Owner",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: deviceSize / 5),
            alignment: Alignment.topCenter,
            child: Text(
              "Chose Your Account",
              style: GoogleFonts.actor(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
