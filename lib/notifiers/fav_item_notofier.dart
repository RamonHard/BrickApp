import 'package:brickapp/models/product_model.dart';
import 'package:brickapp/models/property_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoriteItemListProvider =
    StateNotifierProvider<FavoriteListNotifier, List<PropertyModel>>((ref) {
      return FavoriteListNotifier();
    });

class FavoriteListNotifier extends StateNotifier<List<PropertyModel>> {
  FavoriteListNotifier() : super([]);

  void addToFavorites(PropertyModel item) {
    state = [...state, item]; // Add the item to the favorite list
  }

  void removeFromFavorites(PropertyModel item) {
    state =
        state
            .where((element) => element != item)
            .toList(); // Remove the item from the favorite list
  }

  bool isFavorite(PropertyModel item) {
    return state.contains(item); // Check if the item is in the favorite list
  }
}
