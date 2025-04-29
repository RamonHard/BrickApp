class CreateUser {
  String? userEmail;
  int? userPhone;
  String? passward;
  CreateUser({this.userEmail, this.userPhone, this.passward});
}

class UserLogin {
  String? email;
  int? phone;
  String? passward;
  UserLogin({this.email, this.phone, this.passward});
  Map toMap() {
    return {
      "email": email,
      "phone": phone,
      "passward": passward,
    };
  }
}
