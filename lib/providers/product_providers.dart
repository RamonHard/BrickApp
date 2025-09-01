// import 'package:brickapp/models/property_model.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// final productProvider = StateProvider((ref) {
//   return [
//     PropertyModel(
//       id: 1,
//       propertyType: 'Apartment',
//       location: 'Kampala - City Center',
//       description: 'A beautiful apartment in the heart of Kampala.',
//       price: 200000,
//       currency: 'UGX',
//       bedrooms: 3,
//       baths: 2,
//       sqft: 1200,
//       units: 1,
//       isActive: true,
//       isRent: false,
//       isSale: true,
//       hasParking: true,
//       isFurnished: true,
//       hasAC: true,
//       hasInternet: true,
//       hasSecurity: true,
//       isPetFriendly: false,
//       amenities: ['Gym', 'Pool', 'Security'],
//       productIMG:
//           'https://i.pinimg.com/736x/42/19/f9/4219f9548b8b61162e34dd99638ae04c.jpg',
//       photoPaths: [
//         'https://i.pinimg.com/736x/e0/38/a3/e038a3f80a7c.jpg',
//         'https://i.pinimg.com/736x/6e/89/9d/6e899dba06e6.jpg',
//       ],
//       starRating: 4.5,
//       reviews: 12,
//       uploaderName: 'John Doe',
//       uploaderEmail: 'john@example.com',
//       uploaderIMG:
//           'https://i.pinimg.com/736x/22/03/3e/22033e6449b11e71840b146e867d2229.jpg',
//       uploaderPhoneNumber: 1234567890,
//       insideViews: [
//         'https://i.pinimg.com/736x/aa/c9/9f/aac99fdfd4.jpg',
//         'https://i.pinimg.com/736x/46/e9/eb/46e9ebc1.jpg',
//       ],
//       pendingReason: '',
//       discount: 50000,
//       destinationTitle: 'Brick Apartments',
//     ),

//     PropertyModel(
//       id: 2,
//       propertyType: 'House',
//       location: 'Entebbe',
//       description:
//           'Spacious family house near the airport with a large compound.',
//       price: 350000,
//       currency: 'UGX',
//       bedrooms: 5,
//       baths: 3,
//       sqft: 2000,
//       units: 1,
//       isActive: true,
//       isRent: true,
//       isSale: false,
//       hasParking: true,
//       isFurnished: false,
//       hasAC: false,
//       hasInternet: true,
//       hasSecurity: true,
//       isPetFriendly: true,
//       amenities: ['Security', 'Pet Friendly'],
//       productIMG:
//           'https://i.pinimg.com/1200x/23/72/dc/2372dc681f3198173e712cc581642a11.jpg',
//       photoPaths: ['https://i.pinimg.com/736x/fa/e8/71/fae87126.jpg'],
//       starRating: 4.8,
//       reviews: 8,
//       uploaderName: 'Jane Smith',
//       uploaderEmail: 'jane@example.com',
//       uploaderIMG: 'https://i.pravatar.cc/150?img=5',
//       uploaderPhoneNumber: 987654321,
//       insideViews: [
//         'https://i.pinimg.com/1200x/85/e1/48/85e1480ec0071ad7eafdb9df46d542f9.jpg',
//         'https://i.pinimg.com/736x/76/ba/86/76ba865429d764fffb8e0837bac24d7d.jpg',
//         'https://i.pinimg.com/736x/58/72/b3/5872b392d36e8f20ae75c04489323a49.jpg',
//         'https://i.pinimg.com/736x/e4/f6/6c/e4f66ceedd7ebab7b2036b941807f58d.jpg',
//         'https://i.pinimg.com/736x/df/c3/78/dfc37851602e0c01c419b8d48c4a50c2.jpg',
//       ],
//       pendingReason: '',
//       discount: 100000,
//       destinationTitle: 'Lake View Villa',
//     ),

//     PropertyModel(
//       id: 3,
//       propertyType: 'House',
//       location: 'Jinja',
//       description: 'Modern riverside condo with a stunning view of the Nile.',
//       price: 500000,
//       currency: 'UGX',
//       bedrooms: 2,
//       baths: 2,
//       sqft: 900,
//       units: 10,
//       isActive: false,
//       isRent: true,
//       isSale: true,
//       hasParking: true,
//       isFurnished: true,
//       hasAC: true,
//       hasInternet: true,
//       hasSecurity: true,
//       isPetFriendly: false,
//       amenities: ['Furnished', 'Security', 'Gym', 'AC'],
//       productIMG:
//           'https://i.pinimg.com/1200x/72/e0/41/72e041cdc97711fd10e5352551fe7d7d.jpg',
//       photoPaths: [
//         'https://i.pinimg.com/1200x/6e/89/9d/6e899dba06e6d934c76c1145d656ae44.jpg',
//         'https://i.pinimg.com/736x/e0/38/a3/e038a3f80a7c05bf40e9f9651587a1cc.jpg',
//       ],
//       starRating: 4.2,
//       reviews: 5,
//       uploaderName: 'David Kamau',
//       uploaderEmail: 'david@example.com',
//       uploaderIMG: 'https://i.pravatar.cc/150?img=8',
//       uploaderPhoneNumber: 112233445,
//       insideViews: [
//         'https://i.pinimg.com/736x/aa/c9/9f/aac99fdfd422c2fcd384449e7a918f8d.jpg',
//         'https://i.pinimg.com/1200x/46/e9/eb/46e9ebc108d48e523826b1f9fdda1ce1.jpg',
//         'https://i.pinimg.com/736x/fa/e8/71/fae87126281a06519c0282caee3cbf90.jpg',
//         'https://i.pinimg.com/736x/69/50/b3/6950b3d59c286968db4007e6be8eaa1d.jpg',
//       ],
//       pendingReason: '',
//       discount: 20000,
//       destinationTitle: 'Nile Condominiums',
//     ),
//   ];
// });

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brickapp/models/property_model.dart';

class ProductNotifier extends StateNotifier<List<PropertyModel>> {
  ProductNotifier() : super([]);

  void addProduct(PropertyModel product) {
    state = [...state, product];
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, List<PropertyModel>>((ref) {
      return ProductNotifier();
    });
