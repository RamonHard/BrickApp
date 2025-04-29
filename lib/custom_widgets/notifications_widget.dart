import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestWidget extends StatelessWidget {
  RequestWidget({
    super.key,
    required this.img,
    required this.clientName,
    required this.itemName,
    required this.itemID,
    required this.time,
    required this.amount,
    required this.phone,
  });
  final String img;
  final String clientName;
  final String itemName;
  final int itemID;
  final String time;
  final double amount;
  final int phone;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.lightTextColor, AppColors.backgroundColor],
          ),
          border: Border(
            bottom: BorderSide(
              color: AppColors.orangeTextColor.withOpacity(0.4),
              width: 2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "From:",
                style: GoogleFonts.actor(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTextColor,
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(img),
                ),
                title: Text(
                  clientName,
                  style: GoogleFonts.acme(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ),
              Text(
                "Phone Number: ${phone}",
                style: GoogleFonts.acme(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkTextColor,
                ),
              ),
              Text(
                "Booked: ${itemName}",
                style: GoogleFonts.acme(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextColor,
                ),
              ),
              Text(
                "Item ID: ${itemID}",
                style: GoogleFonts.acme(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextColor,
                ),
              ),
              Text(
                "Date: ${time}",
                style: GoogleFonts.acme(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkTextColor,
                ),
              ),
              Text(
                "Amount:\$ ${amount}",
                style: GoogleFonts.acme(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
