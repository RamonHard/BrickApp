import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class AddPostField extends StatelessWidget {
  AddPostField({Key? key, this.hint}) : super(key: key);
  String? hint;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: TextFormField(
        style: GoogleFonts.ptSerif(
          color: HexColor("3d3d99"),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        keyboardType: TextInputType.number,
        expands: true,
        maxLines: null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8.0),
          suffixIcon: Icon(Icons.money, color: AppColors.textColor),
          hintStyle: GoogleFonts.ptSerif(
            color: HexColor("3d3d99"),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          hintText: hint,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.iconColor),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
