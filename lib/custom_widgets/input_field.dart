import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputFieldWidget extends StatelessWidget {
  InputFieldWidget({
    Key? key,
    required this.hintText,
    this.isObsecure,
    this.textEditingController,
    this.keyBordType,
  }) : super(key: key);
  final String hintText;
  bool? isObsecure;
  TextEditingController? textEditingController;
  TextInputType? keyBordType;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        child: TextField(
          style: GoogleFonts.actor(color: Colors.white, fontSize: 18),
          keyboardType: keyBordType,
          controller: textEditingController,
          obscureText: isObsecure!,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            hintText: '${hintText}',
            hintStyle: GoogleFonts.actor(color: Colors.white, fontSize: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
