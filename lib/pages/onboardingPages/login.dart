import 'dart:ui';
import 'package:brickapp/pages/main_display.dart';
import 'package:brickapp/pages/onboardingPages/forgot_passward.dart';
import 'package:brickapp/pages/onboardingPages/sign_up.dart';
import 'package:brickapp/pages/onboardingPages/user_options.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
// import 'package:http/http.dart' as http;
import '../../custom_widgets/input_field.dart';
import '../../utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  // TabController? tabController;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextStyle style = GoogleFonts.actor(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: HexColor("FFFFFF"),
  );
  TextEditingController emailController = TextEditingController();
  TextEditingController passwardController = TextEditingController();

  final double _sigmax = 0.0;
  final double _sigmay = 0.0;
  final double _opacity = 0.1;
  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('   Book Your \n Next Journey', style: style),
                    Text(
                      "Let's get you Started",
                      style: GoogleFonts.actor(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: HexColor("FFFFFF"),
                      ),
                    ),
                    SizedBox(height: deviceWidth / 10),
                    InputFieldWidget(
                      keyBordType: TextInputType.emailAddress,
                      textEditingController: emailController,
                      isObsecure: false,
                      hintText: 'email',
                    ),
                    SizedBox(height: deviceWidth / 10),
                    InputFieldWidget(
                      keyBordType: TextInputType.visiblePassword,
                      textEditingController: passwardController,
                      isObsecure: true,
                      hintText: 'passward',
                    ),
                    SizedBox(height: deviceWidth / 5),
                    MaterialButton(
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
                      child: Text(
                        'Login',
                        style: GoogleFonts.oxygen(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPassward(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Passward",
                          style: GoogleFonts.oxygen(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            "Dont have an account?",
                            style: GoogleFonts.actor(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: GoogleFonts.actor(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.buttonColor,
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
          ],
        ),
      ),
    );
  }
}
