import 'dart:ui';
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/pages/main_display.dart';
import 'package:brickapp/providers/account_type_provider.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart' as backImg;

class SignUpPage extends ConsumerStatefulWidget {
  SignUpPage({Key? key, this.isClient}) : super(key: key);
  final bool? isClient;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  TextStyle style = GoogleFonts.actor(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  final double _sigmax = 0.0;
  final double _sigmay = 0.0;
  final double _opacity = 0.1;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String selectedCountryCode = '+256';

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

                  // Email Field
                  Text("Email", style: style),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    child: TextField(
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

                  const SizedBox(height: 25),

                  // Password Field
                  Text("Password", style: style),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    child: TextField(
                      controller: passwordController,
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

                  // Phone Number Field with Country Code
                  Text("Phone Number", style: style),
                  const SizedBox(height: 8),
                  _buildPhoneNumberField(),

                  SizedBox(height: 40),

                  // Sign Up Button
                  Container(
                    padding: const EdgeInsets.only(bottom: 50),
                    alignment: Alignment.bottomCenter,
                    child: MaterialButton(
                      minWidth: 150,
                      height: 45,
                      onPressed: _signUp,
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

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Container(
          width: 100,
          child: DropdownButtonFormField<String>(
            value: selectedCountryCode,
            dropdownColor: Colors.grey[900],
            style: TextStyle(color: Colors.white),
            items:
                ['+256', '+255', '+254', '+250'].map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text(code, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCountryCode = value!;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.flag, color: AppColors.iconColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 50,
            child: TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                fillColor: HexColor("ffffff"),
                filled: false,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _signUp() {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String phoneNumber =
        selectedCountryCode + phoneController.text.trim();

    // Basic validation
    if (email.isEmpty || password.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Store user data in Riverpod
    ref.read(userProvider.notifier).setUserData({
      'email': email,
      'phoneNumber': phoneNumber,
      'accountType': AccountType.regular, // Start as regular
      'createdAt': DateTime.now(),
    });

    // Navigate to main display
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainDisplay(isClient: true)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
