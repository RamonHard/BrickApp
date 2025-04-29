import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class ExpansionTileWidget extends StatelessWidget {
  const ExpansionTileWidget(
      {super.key,
      required this.icon,
      required this.text,
      required this.children});
  final IconData icon;
  final String text;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 6.0, left: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ExpansionTile(
          iconColor: AppColors.iconColor,
          expandedAlignment: Alignment.topLeft,
          childrenPadding: EdgeInsets.all(20.0),
          textColor: AppColors.darkTextColor,
          collapsedTextColor: AppColors.darkTextColor,
          collapsedIconColor: AppColors.iconColor,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          collapsedBackgroundColor: HexColor("FFFFFF").withOpacity(0.5),
          backgroundColor: HexColor("FFFFFF").withOpacity(0.5),
          leading: Icon(icon),
          title: Text(
            text,
            style: GoogleFonts.actor(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextColor),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          children: children,
        ),
      ),
    );
  }
}
