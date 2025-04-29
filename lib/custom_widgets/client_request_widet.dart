import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class ClientHistoryWidget extends StatelessWidget {
  const ClientHistoryWidget({
    super.key,
    required this.img,
    required this.clientName,
    required this.itemName,
    required this.itemID,
    required this.time,
    required this.amount,
  });
  final String img;
  final String clientName;
  final String itemName;
  final int itemID;
  final String time;
  final double amount;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: HexColor("FFFFFF").withOpacity(0.5),
          border: Border(
            bottom: BorderSide(
              color: AppColors.iconColor.withOpacity(0.4),
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
                  style: GoogleFonts.actor(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ),
              Text(
                "Booked: ${itemName}",
                style: GoogleFonts.actor(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextColor,
                ),
              ),
              Text(
                "${time}",
                style: GoogleFonts.actor(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Amount:",
                    style: GoogleFonts.actor(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                  Text(
                    " UGX ${amount}",
                    style: GoogleFonts.ptSerif(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
