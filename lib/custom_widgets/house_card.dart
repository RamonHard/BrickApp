import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

// ignore: must_be_immutable
class HouseCard extends StatelessWidget {
  HouseCard({
    Key? key,
    required this.description,
    required this.productimage,
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
  final String productimage;
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
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 8.0),
      child: SizedBox(
        height: 350,
        child: Card(
          elevation: 15.0,
          color: Colors.white,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    InkWell(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(productimage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    if (showDelete == true)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            highlightColor: AppColors.iconColor,
                            onPressed: favOnpress,
                          ),
                        ),
                      )
                    else
                      Container(),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          // Optional: handle button press
                        },
                        child: Text(
                          isActive ? 'Active' : 'Pending',
                          style: TextStyle(
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

              ListTile(
                title: Text(
                  "$houseType",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextColor,
                  ),
                ),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(profileIMG),
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
                    Icon(
                      Icons.bed,
                      color: const Color.fromARGB(255, 128, 127, 127),
                    ),
                    Text(
                      "$bedroomNum",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 128, 127, 127),
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(
                      Icons.square_foot_rounded,
                      color: const Color.fromARGB(255, 128, 127, 127),
                    ),
                    Text(
                      "${sqft}sqft",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 128, 127, 127),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Icon(
                      Icons.house_rounded,
                      color: const Color.fromARGB(255, 128, 127, 127),
                    ),
                    SizedBox(width: 4),
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
                    Icon(Icons.star, color: Colors.amber, size: 15),
                    SizedBox(width: 4.0),
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
                            text: '($reviews)reviews',
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
                      "UGX${price}/m",
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

// ignore: must_be_immutable
