import 'package:brickapp/pages/client_pages/transporter.dart';
import 'package:brickapp/pages/land_and_truck_pages/subscription.dart';
import 'package:brickapp/pages/onboardingPages/change_passward.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../pages/onboardingPages/login.dart';
import '../pages/onboardingPages/register_addpost.dart';
import '../utils/app_colors.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({Key? key}) : super(key: key);

  final TextStyle style = GoogleFonts.actor(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: HexColor('000000'),
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(300)),
      ),
      backgroundColor: HexColor('ffffff'),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('images/brickwall.jpg'),
              ),
            ),
            child: Text(
              "Brick App",
              style: GoogleFonts.actor(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HexColor('FFFFFF'),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterAddPost()),
              );
            },
            leading: Icon(Icons.post_add, color: AppColors.iconColor),
            title: Text('Post', style: style),
          ),
          ListTile(
            onTap: () {
              // Navigator.pop(context);
              // Navigator.of(
              //   context,
              // ).push(MaterialPageRoute(builder: (context) => TruckPage()));
            },
            leading: Icon(Icons.car_rental, color: AppColors.iconColor),
            title: Text('Trucks', style: style),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => Subscription()));
            },
            leading: Icon(Icons.subscriptions, color: AppColors.iconColor),
            title: Text('Subscription', style: style),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ChangePassward()));
            },
            leading: Icon(Icons.lock, color: AppColors.iconColor),
            title: Text('Change Passward', style: style),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              leading: Icon(Icons.logout, color: AppColors.iconColor),
              title: Text('Logout', style: style),
            ),
          ),
        ],
      ),
    );
  }
}
