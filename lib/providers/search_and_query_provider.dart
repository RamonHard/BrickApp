import 'package:hooks_riverpod/hooks_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final truckTypeFilterProvider = StateProvider<String?>((ref) => null);
