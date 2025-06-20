import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:brickapp/models/property_filter_model.dart';

final filterProvider = StateProvider<FilterModel>((ref) => FilterModel());
