import 'package:brickapp/pages/sProviderPages/add_post.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_colors.dart';
import '../../utils/subscription_navigation.dart';

// ignore: must_be_immutable
class Subscription extends StatefulWidget {
  Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  String text =
      'Market like a pro increase your chances of getting potential customers and save time. \n This app makes it possible for a land lord to save up on money and easier for customers to reach out to you.';
  late bool isSubscribed;

  void subScribe(BuildContext context) {
    // isConditionMet(isSubscribed!);
    setState(() {
      isConditionMet(isSubscribed) == true;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => AddPost()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
          ),
          title: Text(
            "Subscription",
            style: GoogleFonts.actor(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          color: AppColors.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                bottom: 20.0,
                right: 8.0,
                left: 8.0,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              "1 Month",
                              style: GoogleFonts.oxygen(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: HexColor("474646"),
                              ),
                            ),
                            Text(
                              "30 USD",
                              style: GoogleFonts.oxygen(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: HexColor("474646"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(
                              "${text}",
                              style: GoogleFonts.oxygen(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 2.0,
                                letterSpacing: 1.0,
                                color: HexColor("474646"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 364,
                        height: 47,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => AddPost(),
                              ),
                            );
                          },
                          color: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Text(
                            "Subscribe",
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HexColor("FFFFFF"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
