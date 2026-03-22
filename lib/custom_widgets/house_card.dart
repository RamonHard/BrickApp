import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';
import '../utils/build_image_method.dart';

class HouseCard extends StatelessWidget {
  HouseCard({
    Key? key,
    required this.description,
    required this.thumbnail,
    required this.location,
    required this.price,
    required this.showDelete,
    required this.onTap,
    this.favOnpress,
    required this.unitsNum,
    this.sqft,
    required this.id,
    required this.profileIMG,
    required this.houseType,
    required this.uploaderName,
    required this.bedroomNum,
    required this.starRating,
    required this.reviews,
    required this.isActive,
  }) : super(key: key);

  final String description;
  final String thumbnail;
  final String location;
  final String houseType;
  final double price;
  final String profileIMG;
  final int id;
  final int unitsNum;
  final String uploaderName;
  final int bedroomNum;
  final bool showDelete;
  double? sqft;
  final double starRating;
  final bool isActive;
  final double reviews;
  final Function() onTap;
  final Function()? favOnpress;

  TextStyle textStyle = GoogleFonts.oxygen(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: HexColor("FFFFFF"),
  );

  @override
  Widget build(BuildContext context) {
    // Convert thumbnail to full URL
    final fullThumbnail = toFullUrl(thumbnail);
    // In build method, after final fullThumbnail = toFullUrl(thumbnail);
    print('🏠 CARD THUMBNAIL INPUT: $thumbnail');
    print('🏠 CARD FULL URL: $fullThumbnail');
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 8.0),
      child: SizedBox(
        height: 350,
        child: Card(
          elevation: 15.0,
          color: Colors.white,
          shadowColor: Colors.black26,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child:
                              fullThumbnail.isEmpty
                                  ? Icon(
                                    Icons.home,
                                    size: 60,
                                    color: Colors.grey[400],
                                  )
                                  : fullThumbnail.startsWith('http')
                                  ? Image.network(
                                    fullThumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (_, __, ___) => Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                  )
                                  : Image.file(
                                    File(fullThumbnail),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (_, __, ___) => Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                  ),
                        ),
                      ),
                      if (showDelete)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white.withOpacity(0.7),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: favOnpress,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isActive ? Colors.green : Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            isActive ? 'Active' : 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  houseType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextColor,
                  ),
                ),
                leading:
                    profileIMG.isNotEmpty
                        ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(toFullUrl(profileIMG)),
                          onBackgroundImageError: (_, __) {},
                        )
                        : CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[500]),
                        ),
                subtitle: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightGrey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bed,
                      color: Color.fromARGB(255, 128, 127, 127),
                    ),
                    Text(
                      '$bedroomNum',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 128, 127, 127),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.square_foot_rounded,
                      color: Color.fromARGB(255, 128, 127, 127),
                    ),
                    Text(
                      sqft != null ? '${sqft}sqft' : 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 128, 127, 127),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    const Icon(
                      Icons.house_rounded,
                      color: Color.fromARGB(255, 128, 127, 127),
                    ),
                    const SizedBox(width: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$unitsNum',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ' Units',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 128, 127, 127),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 20.0,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                    const SizedBox(width: 4.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$starRating',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '($reviews) reviews',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 128, 127, 127),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    Text(
                      'UGX ${price.toStringAsFixed(0)}/m',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
