import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class ProfileTransparentButton extends StatelessWidget {
  const ProfileTransparentButton({
    super.key,
    required this.buttonDescription,
    required this.icon,
    required this.onTap,
  });
  final String buttonDescription;
  final IconData icon;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        color: HexColor("FFFFFF").withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.iconColor),
          title: Text(
            buttonDescription,
            style: GoogleFonts.actor(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
