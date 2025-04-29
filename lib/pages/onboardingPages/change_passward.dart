// ignore_for_file: must_be_immutable

import 'package:brickapp/custom_widgets/change_passward_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';

class ChangePassward extends StatelessWidget {
  ChangePassward({Key? key}) : super(key: key);
  TextStyle style = GoogleFonts.actor(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Change Passward",
            style: GoogleFonts.actor(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          color: AppColors.backgroundColor,
          child: SingleChildScrollView(
            primary: false,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 100),
                  child: Text("Current Passward", style: style),
                ),
                PasswordGlassField(),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text("New Passward", style: style),
                ),
                PasswordGlassField(),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text("Re-type Passward", style: style),
                ),
                PasswordGlassField(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Container(
                    alignment: Alignment.center,
                    child: MaterialButton(
                      height: 45,
                      minWidth: 120,
                      onPressed: () {},
                      color: AppColors.buttonColor,
                      padding: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        "Change",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          color: HexColor("ffffff"),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
