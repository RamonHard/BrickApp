import 'dart:io';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class ViewPostsCard extends StatelessWidget {
  ViewPostsCard({
    Key? key,
    required this.description,
    required this.productimage,
    required this.location,
    required this.price,
    required this.editBtn,
  }) : super(key: key);

  final String description;
  final String productimage; // can be network url OR local path
  final String location;
  final Function() editBtn;
  final double price;

  TextStyle textStyle = GoogleFonts.actor(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HexColor("FFFFFF"),
  );

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
          height: deviceWidth / 2,
          child: Card(
            surfaceTintColor: Colors.transparent,
            elevation: 4,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                    ),
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      child: _buildImage(productimage),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Price: ',
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            Text(
                              '${price} UGX',
                              style: GoogleFonts.ptSerif(
                                fontSize: deviceWidth / 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Location: ',
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            Text(
                              location,
                              style: GoogleFonts.ptSerif(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description:',
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 30,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: MaterialButton(
                            height: 35,
                            minWidth: 50,
                            color: AppColors.iconColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            onPressed: editBtn,
                            child: Text(
                              "Edit",
                              style: GoogleFonts.actor(
                                color: AppColors.lightTextColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
            tooltip: 'Remove',
          ),
        ),
      ],
    );
  }

  /// Helper to display local or network image safely
  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      // Network image
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else {
      // Local image
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
  }

  Widget _errorPlaceholder() => Container(
    color: Colors.grey.shade300,
    child: const Icon(Icons.broken_image, color: Colors.red),
  );
}
