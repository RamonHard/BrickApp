import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconContainer extends StatelessWidget {
  const IconContainer({
    Key? key,
    required this.showIcon,
    required this.onTap,
    required this.iconTitle,
  }) : super(key: key);
  final Icon showIcon;
  final Function() onTap;
  final String iconTitle;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$iconTitle',
      preferBelow: true,
      height: 30,
      textStyle: GoogleFonts.actor(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 68, 68, 68),
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8.0),
          width: 50,
          height: 50,
          child: showIcon,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
