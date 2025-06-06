import 'package:brickapp/models/product_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoriteItemListProvider =
    StateNotifierProvider<FavoriteListNotifier, List<ProductModel>>((ref) {
      return FavoriteListNotifier();
    });

class FavoriteListNotifier extends StateNotifier<List<ProductModel>> {
  FavoriteListNotifier() : super([]);

  void addToFavorites(ProductModel item) {
    state = [...state, item]; // Add the item to the favorite list
  }

  void removeFromFavorites(ProductModel item) {
    state =
        state
            .where((element) => element != item)
            .toList(); // Remove the item from the favorite list
  }

  bool isFavorite(ProductModel item) {
    return state.contains(item); // Check if the item is in the favorite list
  }
}
