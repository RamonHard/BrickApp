import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../utils/app_colors.dart';

class SProviderWidget extends StatelessWidget {
  const SProviderWidget({
    super.key,
    required this.name,
    required this.truckImg,
    required this.profileImg,
    required this.onTap,
  });
  final String name;
  final String truckImg;
  final String profileImg;
  final Function() onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 125,
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.indigo,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(40),
                      ),
                      child: Image.network(truckImg, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipPath(
                      clipper: TrapeziumClipper(),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        width: MediaQuery.of(context).size.width * 3 / 5,
                        decoration: BoxDecoration(
                          color: AppColors.iconColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 6 / 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(profileImg),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      name,
                                      style: GoogleFonts.actor(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.whiteTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Container(
                              //   padding: EdgeInsets.all(10.0),
                              //   child: Text(
                              //     description,
                              //     maxLines: 1,
                              //     overflow: TextOverflow.ellipsis,
                              //     style: GoogleFonts.oxygen(
                              //         fontSize: 12,
                              //         fontWeight: FontWeight.w400,
                              //         color: AppColors.whiteTextColor),
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text(
                                  "View more...",
                                  style: GoogleFonts.actor(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrapeziumClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 2 / 3, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TrapeziumClipper oldClipper) => false;
}
