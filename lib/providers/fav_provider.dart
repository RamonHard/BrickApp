import 'package:brickapp/models/tuck_driver_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteTrucksProvider =
    StateNotifierProvider<FavoriteTrucksNotifier, List<SProviderDriverModel>>((
      ref,
    ) {
      return FavoriteTrucksNotifier();
    });

class FavoriteTrucksNotifier extends StateNotifier<List<SProviderDriverModel>> {
  FavoriteTrucksNotifier() : super([]);

  void toggleFavorite(SProviderDriverModel truck) {
    final index = state.indexWhere((element) => element == truck);
    if (index != -1) {
      state[index].isFavorite == state[index].isFavorite;
      state = List.from(state);
    }
  }
}
