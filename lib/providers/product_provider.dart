// Local product provider — for property manager's own posts
// Initialized from backend via myListingsFamilyProvider
import 'package:brickapp/models/property_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProductNotifier extends StateNotifier<List<PropertyModel>> {
  ProductNotifier() : super([]);

  void addProduct(PropertyModel product) {
    state = [...state, product];
  }

  void updateProduct(PropertyModel updatedProduct) {
    state =
        state.map((p) {
          return p.id == updatedProduct.id ? updatedProduct : p;
        }).toList();
  }

  void removeProduct(int id) {
    state = state.where((p) => p.id != id).toList();
  }

  void setProducts(List<PropertyModel> products) {
    state = products;
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, List<PropertyModel>>(
      (ref) => ProductNotifier(),
    );
