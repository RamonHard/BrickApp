import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:brickapp/notifiers/fav_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/app_colors.dart';

class TruckDetailed extends HookConsumerWidget {
  const TruckDetailed({super.key, required this.truck});
  final TruckDriverModel truck;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = MediaQuery.of(context).size.width;
    final reachOut = useState(false);
    final isFavorite = ref.watch(
      favoriteListProvider.select((favorites) => favorites.contains(truck)),
    );
    final favoriteListNotifier = ref.read(favoriteListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.iconColor),
        ),
        title: Text(
          "Transportation",
          style: GoogleFonts.oxygen(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isFavorite) {
                favoriteListNotifier.removeFromFavorites(truck);
              } else {
                favoriteListNotifier.addToFavorites(truck);
              }
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: deviceSize / 10),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(truck.profileImg),
            ),
            Text(
              truck.name,
              style: GoogleFonts.oxygen(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 10),
            Container(
              child:
                  reachOut.value
                      ? Column(
                        children: [
                          Text(
                            truck.email,
                            style: GoogleFonts.oxygen(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Phone: ${truck.phone}",
                            style: GoogleFonts.oxygen(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      )
                      : Container(),
            ),
            SizedBox(height: deviceSize / 20),
            Container(
              // height: deviceSize / 2,
              decoration: BoxDecoration(
                color: HexColor("FFFFFF"),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: 150,
                          width: deviceSize,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(truck.truckImg),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Location: ${truck.location}",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Starting price ${truck.startingPrice}\$",
                        style: GoogleFonts.actor(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: deviceSize / 25),
                    // Text(
                    //   truckDescription,
                    //   style: GoogleFonts.actor(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //     color: AppColors.textColor,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(height: deviceSize / 15),
            MaterialButton(
              height: 40,
              minWidth: 100,
              onPressed: () {
                reachOut.value = !reachOut.value;
              },
              color: AppColors.iconColor,
              child: Text(
                "Reach Out",
                style: GoogleFonts.actor(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
