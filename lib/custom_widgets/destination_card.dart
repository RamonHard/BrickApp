// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.img,
    required this.onTap,
    required this.id,
    required this.price,
    required this.location,
    required this.description,
  }) : super(key: key);
  final String img;
  final int id;
  final double price;
  final String location;
  final String description;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 20,
        right: 20,
      ),
      child: Container(
        // height: 250,
        // constraints: BoxConstraints(maxHeight: 400, minHeight: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: HexColor("FFFFFF"),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Location: ${location}",
                    style: GoogleFonts.oxygen(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Price: ",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      Text(
                        "\$$price",
                        style: GoogleFonts.oxygen(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.sell_rounded, color: HexColor("33EF07")),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.oxygen(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
