import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/notifiers/fav_notifier.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewFavourite extends HookConsumerWidget {
  const ViewFavourite({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favData = ref.watch(favoriteListProvider);
    final favoriteListNotifier = ref.read(favoriteListProvider.notifier);
    if (favData is AsyncLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (favData is AsyncError) {
      return Center(child: Text('Error: ${favData}'));
    } else {
      final favList = favData;
      if (favList.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
            ),
            centerTitle: true,
            title: Text(
              "Your Efficient Truck Driver",
              style: GoogleFonts.actor(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: AppColors.backgroundColor,
          ),
          body: ListView.builder(
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final TruckDriverModel truck = favList[index];
              return Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.orangeTextColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(truck.profileImg),
                    ),
                    title: Text(truck.name),
                    subtitle: Text(truck.email),
                    trailing: IconButton(
                      onPressed: () {
                        favoriteListNotifier.removeFromFavorites(truck);
                      },
                      icon: const Icon(Icons.delete, color: Colors.black45),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return Center(child: Text('No favorites yet'));
      }
    }
  }
}
