import 'dart:io';
import 'package:brickapp/custom_widgets/add_post_field.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

class PostTruckPage extends StatefulWidget {
  PostTruckPage({super.key});

  @override
  State<PostTruckPage> createState() => _PostTruckPageState();
}

class _PostTruckPageState extends State<PostTruckPage> {
  final bool isSuccess = true;

  TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextColor,
  );

  XFile? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
        centerTitle: true,
        title: Text(
          "Post Truck",
          style: GoogleFonts.actor(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: deviceSize / 10),
            Row(
              children: [
                Expanded(child: Text("Rent Price: ", style: style)),
                Expanded(flex: 2, child: AddPostField()),
              ],
            ),
            SizedBox(height: deviceSize / 10),
            Row(
              children: [
                Expanded(child: Text("Truck Model: ", style: style)),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    child: TextField(
                      style: GoogleFonts.actor(
                        color: HexColor("3d3d99"),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0),
                        hintStyle: GoogleFonts.actor(
                          color: HexColor("3d3d99"),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        hintText: 'Ford',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.iconColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: deviceSize / 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Add Truck Image",
                style: GoogleFonts.actor(
                  color: AppColors.darkTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Center(
              child:
                  _image == null
                      ? Container(
                        height: 200,
                        width: deviceSize,
                        child: InkWell(
                          onTap: _getImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'No image selected.',
                                style: GoogleFonts.actor(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.darkTextColor,
                                ),
                              ),
                              Positioned(
                                bottom: 40,
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppColors.darkTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : InkWell(
                        onTap: _getImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              File(_image!.path),
                              width: deviceSize,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: AppColors.lightTextColor,
                              size: 35,
                            ),
                          ],
                        ),
                      ),
            ),
            SizedBox(height: deviceSize / 5),
            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                height: 45,
                minWidth: 100,
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
                                      "Your post has been successfully uploaded.",
                                      style: GoogleFonts.actor(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      "Failed to upload",
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
                  isSuccess
                      ? MainNavigation.navigateToRoute(
                        MainNavigation.landAndTruckProfileRoute,
                      )
                      : null;
                },
                color: AppColors.buttonColor,
                padding: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Submmit",
                  style: GoogleFonts.actor(
                    fontSize: 16,
                    color: HexColor("ffffff"),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
