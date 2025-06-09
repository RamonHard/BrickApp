import 'package:brickapp/pages/sProviderPages/profile.dart';
import 'package:brickapp/pages/sProviderPages/subscription.dart';

isConditionMet(bool isSubscribed) {
  if (isSubscribed == true) {
    return LandAndTruckProfilePage();
  }
  if (isSubscribed == false) {
    return Subscription();
  }
}
