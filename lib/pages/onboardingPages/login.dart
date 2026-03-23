import 'dart:ui';
import 'package:brickapp/custom_widgets/phone_number_input_field.dart';
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/pages/main_display.dart';
import 'package:brickapp/pages/onboardingPages/forgot_passward.dart';
import 'package:brickapp/pages/onboardingPages/sign_up.dart';
import 'package:brickapp/pages/onboardingPages/user_options.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:http/http.dart' as http;
import '../../custom_widgets/input_field.dart';
import '../../providers/account_type_provider.dart';
import '../../utils/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  // TabController? tabController;
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextStyle style = GoogleFonts.actor(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: HexColor("FFFFFF"),
  );
  TextEditingController phoneController = TextEditingController();
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
                    PhoneInputField(
                      textEditingController:
                          phoneController, // you can rename later
                      hintText: '789xxxxxxx',
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
                      onPressed: _loginUser,
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

  Future<void> _loginUser() async {
    final phone = phoneController.text.trim();
    final password = passwardController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppUrls.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      final data = jsonDecode(response.body);
      print("LOGIN RESPONSE: $data");

      if (response.statusCode == 200 && data['status'] == true) {
        // ✅ Save user + token properly
        // ✅ Save basic user + token
        ref
            .read(userProvider.notifier)
            .setFromBackend(data['user'], data['token']);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful')));

        // ✅ Route based on role
        final user = ref.read(userProvider);
        final isClient = user.isClient || user.isAdmin;
        final profileResponse = await http.get(
          Uri.parse(AppUrls.profile),
          headers: {'Authorization': 'Bearer ${data['token']}'},
        );
        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          ref
              .read(userProvider.notifier)
              .setFromBackend(profileData['user'], data['token']);
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDisplay(isClient: isClient),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
