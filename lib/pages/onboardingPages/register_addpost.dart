import 'dart:ui';
import 'package:brickapp/pages/main_display.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class RegisterAddPost extends StatefulWidget {
  final bool? isClient;
  RegisterAddPost({super.key, this.isClient});

  @override
  State<RegisterAddPost> createState() => _RegisterAddPostState();
}

class _RegisterAddPostState extends State<RegisterAddPost> {
  TextStyle style = GoogleFonts.actor(
    fontSize: 16,
    color: HexColor("FFFFFF"),
    fontWeight: FontWeight.w600,
  );

  final double _sigmax = 0.0;

  final double _sigmay = 0.0;

  final double _opacity = 0.1;

  double sizedbox = 20.0;
  int? selectedValue;
  Color activeColor = AppColors.iconColor;
  Color disabledColor = AppColors.textColor;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController idNINController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // final deviceSize = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(0, 253, 213, 213),
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
          // alignment: Alignment.center,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/brickwall.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
                child: Container(color: Colors.black.withOpacity(_opacity)),
              ),
            ),
            SingleChildScrollView(
              primary: false,
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 50, bottom: 50),
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Start Posting business Content',
                      style: GoogleFonts.actor(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text("Full Name", style: style),
                  Container(
                    height: 50,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      controller: userNameController,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      obscureText: false,
                      decoration: InputDecoration(
                        fillColor: HexColor("ffffff"),
                        filled: false,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sizedbox),
                  Text("Business Email", style: style),
                  Container(
                    height: 50,
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      obscureText: false,
                      decoration: InputDecoration(
                        fillColor: HexColor("ffffff"),
                        filled: false,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sizedbox),
                  Text("Business Phone Number", style: style),
                  Container(
                    height: 50,
                    child: TextField(
                      controller: phoneNumController,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      obscureText: false,
                      decoration: InputDecoration(
                        fillColor: HexColor("ffffff"),
                        filled: false,
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sizedbox),
                  Text("Upload ID Photo", style: style),
                  Container(
                    height: 150,
                    width: 300,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      color: Colors.transparent,
                      elevation: 0,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: sizedbox),
                  Text("Upload Passport Photo", style: style),
                  Container(
                    height: 150,
                    width: 300,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      color: Colors.transparent,
                      elevation: 0,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: sizedbox),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          activeColor: AppColors.iconColor,
                          title: Text(
                            "Male",
                            style: GoogleFonts.oxygen(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                          value: 1,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RadioListTile(
                          activeColor: AppColors.iconColor,
                          title: Text(
                            "Female",
                            style: GoogleFonts.oxygen(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                          value: 2,
                          groupValue: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizedbox),
                  Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      minWidth: 150,
                      height: 45,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainDisplay(),
                          ),
                        );
                      },
                      color: AppColors.buttonColor,
                      padding: const EdgeInsets.all(8.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const Text(
                        'Submmite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.visible,
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
