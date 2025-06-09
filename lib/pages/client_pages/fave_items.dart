import 'package:brickapp/custom_widgets/house_card.dart';
import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/notifiers/fav_item_notofier.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavouriteItemList extends HookConsumerWidget {
  const FavouriteItemList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favData = ref.watch(favoriteItemListProvider);
    final favoriteItemListNotifier = ref.read(
      favoriteItemListProvider.notifier,
    );
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
              final ProductModel product = favList[index];
              return HouseCard(
                description: product.description,
                productimage: product.productIMG,
                location: product.location,
                price: product.price,
                onTap: () {
                  MainNavigation.navigateToRoute(
                    MainNavigation.viewSelectedProductRoute,
                    data: product,
                  );
                },
                favOnpress: () {
                  favoriteItemListNotifier.removeFromFavorites(product);
                },
                unitsNum: product.unitsNum,
                id: product.id,
                profileIMG: product.uploaderIMG,
                houseType: product.houseType,
                uploaderName: product.uploaderName,
                bedroomNum: product.bedRoomNum,
                starRating: product.starRating,
                reviews: product.reviews,
                isActive: product.isActive,
                showDelete: true,
              );
            },
          ),
        );
      } else {
        return Center(child: Text('All your favorites Items will appear here'));
      }
    }
  }
}
