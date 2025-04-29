// ignore_for_file: must_be_immutable

import 'dart:ui';
import 'package:brickapp/custom_widgets/change_passward_field.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangeClientPassword extends HookConsumerWidget {
  ChangeClientPassword({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final bool isSuccess = true;
  String currentPassword = 'ramon';
  String newPassword = 'hard';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final textError = useState(false);
    final newPinError = useState(false);
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
                    image: AssetImage(AppImages.backImg),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: deviceWidth / 10),
                      Text(
                        "Current Password",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: deviceWidth / 30),
                      PasswordGlassField(
                        onSaved: (String? value) {
                          currentPassword == value;
                        },
                        validator: (String? value) {
                          if (value == null || value.trim() == '') {
                            textError.value = true;
                          }
                          return null;
                        },
                      ),
                      Container(
                        child:
                            textError.value != false
                                ? Text("Pin is Required!")
                                : null,
                      ),
                      SizedBox(height: deviceWidth / 10),
                      Text(
                        "New Password",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: deviceWidth / 30),
                      PasswordGlassField(
                        onSaved: (String? value) {
                          newPassword == value;
                        },
                        validator: (String? value) {
                          if (value == null || value.trim() == '') {
                            newPinError.value = true;
                          }
                          return null;
                        },
                      ),
                      Container(
                        child:
                            textError.value != false
                                ? Text("New Pin is Required!")
                                : null,
                      ),
                      SizedBox(height: deviceWidth / 10),
                      Text(
                        "Confirm Password",
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      SizedBox(height: deviceWidth / 30),
                      PasswordGlassField(
                        validator: (String? value) {
                          if (newPassword == null) {
                            newPinError.value = true;
                          }
                          if (newPassword != value) {
                            return 'Pins do not match';
                          }

                          return null;
                        },
                      ),
                      Container(
                        child:
                            textError.value != false
                                ? Text("New Pin is Required!")
                                : null,
                      ),
                      SizedBox(height: deviceWidth / 10),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: MaterialButton(
                          height: deviceWidth / 6.5,
                          minWidth: deviceWidth / 2.5,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
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
                                            ? AppColors.iconColor.withOpacity(
                                              0.4,
                                            )
                                            : AppColors.darkBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                  "Password has been changed successfully",
                                                  style: GoogleFonts.actor(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                )
                                                : Text(
                                                  "Failed to change password",
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
                            }
                            return null;
                          },
                          padding: EdgeInsets.all(4.0),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
