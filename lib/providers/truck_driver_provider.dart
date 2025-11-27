// providers/truck_provider.dart
import 'package:brickapp/models/truck_driver_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Mock current user ID (in real app, get from authentication)
final currentUserIdProvider = StateProvider<String>((ref) => 'user_123');

class TruckNotifier extends StateNotifier<List<Truck>> {
  TruckNotifier() : super([]);

  void addTruck(Truck truck) {
    state = [...state, truck];
  }

  void removeTruck(String truckId) {
    state = state.where((truck) => truck.id != truckId).toList();
  }

  void updateTruck(String truckId, Truck updatedTruck) {
    state =
        state
            .map((truck) => truck.id == truckId ? updatedTruck : truck)
            .toList();
  }

  void toggleAvailability(String truckId) {
    state =
        state.map((truck) {
          if (truck.id == truckId) {
            return truck.copyWith(isAvailable: !truck.isAvailable);
          }
          return truck;
        }).toList();
  }

  // Get all available trucks for clients
  List<Truck> getAvailableTrucks() {
    return state.where((truck) => truck.isAvailable).toList();
  }

  // Get trucks posted by current user
  List<Truck> getMyTrucks(String ownerId) {
    return state.where((truck) => truck.ownerId == ownerId).toList();
  }

  List<Truck> getTrucksByType(String vehicleType) {
    return state
        .where((truck) => truck.vehicleType == vehicleType && truck.isAvailable)
        .toList();
  }
}

final truckProvider = StateNotifierProvider<TruckNotifier, List<Truck>>((ref) {
  return TruckNotifier();
});

// Provider for available trucks (client view)
final availableTrucksProvider = Provider<List<Truck>>((ref) {
  final trucks = ref.watch(truckProvider);
  return trucks.where((truck) => truck.isAvailable).toList();
});

// Provider for my trucks (truck driver view)
final myTrucksProvider = Provider<List<Truck>>((ref) {
  final trucks = ref.watch(truckProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  return trucks.where((truck) => truck.ownerId == currentUserId).toList();
});
