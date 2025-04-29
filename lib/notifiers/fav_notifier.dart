import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoriteListProvider =
    StateNotifierProvider<FavoriteListNotifier, List<TruckDriverModel>>((ref) {
      return FavoriteListNotifier();
    });

class FavoriteListNotifier extends StateNotifier<List<TruckDriverModel>> {
  FavoriteListNotifier() : super([]);

  void addToFavorites(TruckDriverModel item) {
    state = [...state, item]; // Add the item to the favorite list
  }

  void removeFromFavorites(TruckDriverModel item) {
    state =
        state
            .where((element) => element != item)
            .toList(); // Remove the item from the favorite list
  }

  bool isFavorite(TruckDriverModel item) {
    return state.contains(item); // Check if the item is in the favorite list
  }
}
