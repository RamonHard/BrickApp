import 'package:flutter/material.dart';

class DrawerWidget1 extends StatelessWidget {
  const DrawerWidget1(
      {Key? key,
      required this.tabController,
      required String userEmail,
      required String userImage,
      required String userNmae})
      : super(key: key);
  final TabController tabController;
  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
        currentAccountPicture: CircleAvatar(
            backgroundImage: NetworkImage(
                'https://otakukart.com/wp-content/uploads/2022/05/One-Piece-7.jpg')),
        accountName: Text('Ramon HL'),
        accountEmail: Text('LuckHard@gmail.com'));
  }
}
