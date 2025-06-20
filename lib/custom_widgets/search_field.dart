import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class SearchCard extends StatelessWidget {
  SearchCard({Key? key, required this.hintText, this.onChanged})
    : super(key: key);
  final String hintText;
  dynamic Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: const Color.fromARGB(255, 172, 171, 171).withOpacity(0.4),
        ),
        child: TextFormField(
          style: GoogleFonts.actor(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            focusColor: Colors.transparent,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.actor(
              fontSize: 13,
              color: AppColors.darkTextColor,
            ),
            suffixIcon: Icon(Icons.search, color: Colors.black),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}
