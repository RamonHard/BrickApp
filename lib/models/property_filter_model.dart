class FilterModel {
  final List<String> selectedDescriptions;
  final double? fromPrice;
  final double? toPrice;
  final Map<String, bool> selectedAmenities;

  FilterModel({
    this.selectedDescriptions = const [],
    this.fromPrice,
    this.toPrice,
    this.selectedAmenities = const {},
  });
}
