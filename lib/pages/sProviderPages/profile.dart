import 'dart:io';
import 'dart:ui';
import 'package:brickapp/custom_widgets/profile_transparent_widget.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../../custom_widgets/custom_expansion_list.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart' as appImg;

class LandAndTruckProfilePage extends StatefulWidget {
  LandAndTruckProfilePage({
    super.key,
    this.emailController,
    this.phoneNumController,
    this.userNameController,
    this.selectedGender,
  });
  final TextEditingController? emailController;
  final TextEditingController? phoneNumController;
  final TextEditingController? userNameController;
  final int? selectedGender;
  @override
  State<LandAndTruckProfilePage> createState() =>
      _LandAndTruckProfilePageState();
}

class _LandAndTruckProfilePageState extends State<LandAndTruckProfilePage> {
  TextStyle userInfoStyle = GoogleFonts.actor(
    fontSize: 16,
    color: HexColor("#d8e2dc"),
    fontWeight: FontWeight.w500,
  );

  EdgeInsets padding = EdgeInsets.all(8.0);

  File? selectedImage;

  Future pickImage() async {
    try {
      final selectedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (selectedImage == null) return;
      final imageTemporary = File(selectedImage.path);
      setState(() => this.selectedImage = imageTemporary);
    } on PlatformException catch (e) {
      print("Failed to pick image at : ${e}");
    }
  }

  String getSelectedGenger() {
    switch (widget.selectedGender) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'No gender was selected';
    }
  }

  final double _sigmax = 4.0;
  final double _sigmay = 4.0;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: Container(),
          title: Text(
            "Profile",
            style: GoogleFonts.actor(
              fontSize: 18,
              color: AppColors.lightTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        //
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(appImg.AppImages.backImg),
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
              primary: true,
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: deviceSize / 5),
                  Container(
                    alignment: Alignment.topCenter,
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepOrange,
                      backgroundImage: NetworkImage(
                        "https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Ramon Hardluck",
                    style: GoogleFonts.actor(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextColor,
                    ),
                  ),
                  ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: [
                      SizedBox(height: deviceSize / 30),

                      SizedBox(height: deviceSize / 30),
                      ProfileTransparentButton(
                        buttonDescription: "Edit Profile",
                        icon: Icons.camera_alt_outlined,
                        onTap: () {},
                      ),
                      SizedBox(height: deviceSize / 30),
                      ProfileTransparentButton(
                        buttonDescription: "Logout",
                        icon: Icons.logout,
                        onTap: () {},
                      ),
                    ],
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
