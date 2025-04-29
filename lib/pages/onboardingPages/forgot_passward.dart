import 'dart:ui';
import 'package:brickapp/custom_widgets/custom_text_field.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart' as backImg;

class ForgotPassward extends StatelessWidget {
  final TextStyle style = GoogleFonts.actor(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: HexColor("FFFFFF"),
  );

  final double _sigmax = 0.0;
  final double _sigmay = 0.0;
  final double _opacity = 0.1;
  final bool isSuccess = true;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.iconColor,
            size: 35,
          ),
        ),
      ),
      body: Stack(
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
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
              child: Container(color: Colors.black.withOpacity(_opacity)),
            ),
          ),
          Container(color: Colors.black.withOpacity(_opacity)),
          SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('    Reset \n Passward ', style: style),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Create your new passward with Brick",
                      style: GoogleFonts.oxygen(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: HexColor("FFFFFF"),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 1 / 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Create New Passward",
                          style: GoogleFonts.oxygen(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      CustomTextField(hintText: 'Create your new passward'),
                    ],
                  ),
                  SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Confirm new passward",
                          style: GoogleFonts.oxygen(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      CustomTextField(hintText: 'Confirm new passward'),
                    ],
                  ),
                  SizedBox(height: screenHeight * 1 / 8),
                  MaterialButton(
                    minWidth: 200,
                    height: 50,
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
                                          "Your password has been changed",
                                          style: GoogleFonts.actor(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Text(
                                          "Failed to Change password",
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
                    color: AppColors.buttonColor,
                    padding: const EdgeInsets.all(8.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Text(
                      'Reset Passward',
                      style: GoogleFonts.oxygen(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
