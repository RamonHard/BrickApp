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
  final String productimage;
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
                      image: DecorationImage(
                        image: NetworkImage(productimage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: double.infinity,
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
                              'Locatin: ',
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                            Text(
                              '$location',
                              style: GoogleFonts.ptSerif(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Description:',
                              style: GoogleFonts.actor(
                                fontSize: deviceWidth / 25,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${description}',
                          maxLines: 2,
                          style: GoogleFonts.actor(
                            fontSize: deviceWidth / 30,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextColor,
                          ),
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
            icon: Icon(Icons.cancel, color: Colors.red, size: 20),
            tooltip: 'Remove',
          ),
        ),
      ],
    );
  }
}
