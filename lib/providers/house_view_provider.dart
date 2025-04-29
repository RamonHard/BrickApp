import 'package:brickapp/models/house_views_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final houseViewProvider = Provider((ref) {
  return [
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/08/6d/fb/086dfb4f965aa767d64a5ede2199ca11.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/00/9c/23/009c2364f647c6b6bd4c1333cb9fabd7.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/93/60/7b/93607bf1f9242b6674e17bb5ede14d4e.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/6f/d5/2a/6fd52a2bc35f99f4b7bb384dbfd0a377.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/49/61/63/4961634763ca374221befdca9cb86084.jpg',
    ),
    HouseViewsModel(
      insideView:
          'https://i.pinimg.com/736x/81/dc/cb/81dccb33f129d86f77843324b5b76c9f.jpg',
    ),
  ];
});
