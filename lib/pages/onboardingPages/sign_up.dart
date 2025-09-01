import 'dart:ui';
import 'package:brickapp/pages/main_display.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart' as backImg;

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key, this.isClient}) : super(key: key);
  final bool? isClient;
  TextStyle style = GoogleFonts.actor(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  final double _sigmax = 0.0;
  final double _sigmay = 0.0;
  final double _opacity = 0.1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
                child: Container(color: Colors.black.withOpacity(_opacity)),
              ),
            ),
            SingleChildScrollView(
              primary: false,
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 80, bottom: 80),
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.actor(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text("Email", style: style),
                  Container(
                    height: 50,
                    child: TextField(
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
                  const SizedBox(height: 25),
                  Text("Passward", style: style),
                  Container(
                    height: 50,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      obscureText: true,
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
                  const SizedBox(height: 25),
                  Text("Phone Number", style: style),
                  Container(
                    height: 50,
                    child: TextField(
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
                  SizedBox(height: 20),
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
                            builder: (context) => MainDisplay(isClient: true),
                          ),
                        );
                      },
                      color: AppColors.buttonColor,
                      padding: const EdgeInsets.all(8.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      child: const Text(
                        'Sign Up',
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
