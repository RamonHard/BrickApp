class UserModel {
  final String profileIMG;
  final String name;
  final String email;
  final String phone;
  final String accountType;
  final String houseDescription;
  final int id;
  UserModel(
      {required this.profileIMG,
      required this.name,
      required this.email,
      required this.phone,required this.accountType,
      required this.id,
      required this.houseDescription});
}
