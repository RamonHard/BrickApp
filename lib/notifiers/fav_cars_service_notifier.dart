import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final favoriteListProvider =
    StateNotifierProvider<FavoriteListNotifier, List<SProviderDriverModel>>((
      ref,
    ) {
      return FavoriteListNotifier();
    });

class FavoriteListNotifier extends StateNotifier<List<SProviderDriverModel>> {
  FavoriteListNotifier() : super([]);

  void addToFavorites(SProviderDriverModel item) {
    state = [...state, item]; // Add the item to the favorite list
  }

  void removeFromFavorites(SProviderDriverModel item) {
    state =
        state
            .where((element) => element != item)
            .toList(); // Remove the item from the favorite list
  }

  bool isFavorite(SProviderDriverModel item) {
    return state.contains(item); // Check if the item is in the favorite list
  }
}
