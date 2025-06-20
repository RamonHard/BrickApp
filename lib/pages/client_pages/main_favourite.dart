import 'package:brickapp/pages/client_pages/fave_items.dart';
import 'package:brickapp/pages/client_pages/favorite_s_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainFavoriteDisplay extends StatelessWidget {
  const MainFavoriteDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Item and SProvider
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Favorites',
            style: GoogleFonts.oxygen(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textColor,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Color.fromARGB(172, 255, 115, 0),
            tabs: [Tab(text: 'Items'), Tab(text: 'SProviders')],
          ),
        ),
        body: TabBarView(
          children: [FavouriteItemList(), Container(child: Text("Fav Truck"))],
        ),
      ),
    );
  }
}
