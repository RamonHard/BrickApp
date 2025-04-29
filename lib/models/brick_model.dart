class BrickModel {
  final int id;
  final String title;
  final String description;
  BrickModel(
      {required this.id, required this.title, required this.description});

  factory BrickModel.fromJson(Map<String, dynamic> json) {
    return BrickModel(
        id: json['id'], title: json['title'], description: json['description']);
  }
}
