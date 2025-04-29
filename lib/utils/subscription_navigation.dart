import 'package:brickapp/pages/land_and_truck_pages/profile.dart';
import 'package:brickapp/pages/land_and_truck_pages/subscription.dart';

isConditionMet(bool isSubscribed) {
  if (isSubscribed == true) {
    return LandAndTruckProfilePage();
  }
  if (isSubscribed == false) {
    return Subscription();
  }
}
