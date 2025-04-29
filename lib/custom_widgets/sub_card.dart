import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class SubCard extends StatelessWidget {
  const SubCard({super.key, required this.month, required this.amount});
  final int month;
  final int amount;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      height: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                "${month}Month",
                style: GoogleFonts.oxygen(
                    fontSize: 18, color: AppColors.textColor),
              ),
              Text(
                "${amount} USD",
                style: GoogleFonts.oxygen(
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                    color:AppColors.textColor),
              ),
              Text(
                "Easy way to market your Property.\nMeet new and potential Customers to rent houses",
                style: GoogleFonts.oxygen(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: AppColors.textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
