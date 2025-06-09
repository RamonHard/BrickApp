import 'package:brickapp/custom_widgets/truck_widget.dart';
import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/notifiers/fav_cars_service_notifier.dart';
import 'package:brickapp/pages/client_pages/tuck_detailed.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavoriteSProvider extends HookConsumerWidget {
  const FavoriteSProvider({Key? key}) : super(key: key);

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
          body: ListView.builder(
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final SProviderDriverModel sProvider = favList[index];
              return SProviderWidget(
                name: sProvider.name,
                profileImg: sProvider.profileImg,
                truckImg: sProvider.truckImg,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (BuildContext context) =>
                              DriverProfilePage(driverModel: sProvider),
                    ),
                  );
                },
              );
            },
          ),
        );
      } else {
        return Center(
          child: Text('All your favorites service Providers will be here'),
        );
      }
    }
  }
}
