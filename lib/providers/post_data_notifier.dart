import 'package:brickapp/models/add_post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDataNotifier extends StateNotifier<PostData> {
  PostDataNotifier()
    : super(
        PostData(
          propertyType: 'House',
          location: 'Kampala',
          price: null,
          discount: null,
          commission: null,
          currency: 'UGX',
          bedrooms: 3,
          baths: 2,
          sqft: 1200,
          units: 1,
          isActive: true,
          pendingReason: null,
          isRent: false,
          isSale: false,
          hasParking: false,
          isFurnished: false,
          hasAC: false,
          hasInternet: false,
          hasSecurity: false,
          isPetFriendly: false,
          description: '',
          photoPaths: [],
        ),
      );

  void update(PostData newData) => state = newData;
  void updateField<T>(T Function(PostData data) updateFn) {
    state = updateFn(state) as PostData;
  }
}

final postDataProvider = StateNotifierProvider<PostDataNotifier, PostData>(
  (ref) => PostDataNotifier(),
);
