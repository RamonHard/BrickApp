import 'package:brickapp/pages/main_display.dart';
import 'package:flutter/material.dart';

class AccountSetUp extends StatelessWidget {
  AccountSetUp({super.key, required this.isClient});
  final bool isClient;
  @override
  Widget build(BuildContext context) {
    return Container(child: setAccountType(context, isClient));
  }
}

setAccountType(BuildContext context, bool isClient) {
  if (isClient == true) {
    return MainDisplay(isClient: true);
  } else if (isClient == false) {
    return MainDisplay(isClient: false);
  }
}
