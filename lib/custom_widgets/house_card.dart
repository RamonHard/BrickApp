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
    required this.onTap,
    required this.id,
    required this.profileIMG,
    required this.uploaderName,
  }) : super(key: key);
  final String description;
  final String productimage;
  final String location;
  final double price;
  final String profileIMG;
  final int id;
  final String uploaderName;
  final Function() onTap;
  TextStyle textStyle = GoogleFonts.oxygen(
      fontSize: 16, fontWeight: FontWeight.w600, color: HexColor("FFFFFF"));
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: deviceWidth / 1.7,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HexColor("FFFFFF").withOpacity(0.5),
            borderRadius: BorderRadius.circular(45),
          ),
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: deviceWidth / 1.5,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.network(
                    productimage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45.0),
                    topRight: Radius.circular(45.0),
                  ),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  leading: Container(
                    padding: EdgeInsets.all(2.0),
                    alignment: Alignment.center,
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: HexColor("#ced2d9"),
                        borderRadius: BorderRadius.circular(100)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(profileIMG),
                    ),
                  ),
                  title: Text(
                    uploaderName,
                    style: textStyle,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.actor(
                        color: HexColor('e0d7fe'), fontWeight: FontWeight.w300),
                  ),
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
