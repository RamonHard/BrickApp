import 'package:brickapp/providers/truck_driver_provider.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/utils/app_colors.dart';

class MainDisplay extends HookConsumerWidget {
  final bool? isClient;

  MainDisplay({super.key, this.isClient});
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ  $isClient");

    return Scaffold(
      body: Navigator(
        key: NavigatorKeys.mainKey,
        onGenerateRoute: (settings) {
          return MainNavigation.onGenerateRoute(settings, isClient!);
        },
      ),
      bottomNavigationBar: getNavBar(selectedIndex),
    );
  }

  Widget getNavBar(ValueNotifier<int> selectedIndex) {
    if (isClient == true) {
      return ClientNavBar(selectedIndex: selectedIndex);
    }
    print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ2  $isClient");
    return LandAndTruckNavBar(selectedIndex: selectedIndex);
  }
}

class ClientNavBar extends ConsumerWidget {
  const ClientNavBar({super.key, required this.selectedIndex});

  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final s = ref.watch(serviceProvider);
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.orangeTextColor, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: HexColor("FFFFFF").withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.actor(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.iconColor,
        ),
        unselectedLabelStyle: GoogleFonts.ptSerif(
          fontSize: 14,
          fontWeight: FontWeight.w200,
          color: AppColors.darkTextColor,
        ),
        unselectedIconTheme: IconThemeData(color: AppColors.darkTextColor),
        items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: 'Transporter',
            icon: Icon(Icons.car_rental),
          ),
          BottomNavigationBarItem(label: 'History', icon: Icon(Icons.history)),

          BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person)),
        ],
        currentIndex: selectedIndex.value,
        fixedColor: AppColors.iconColor,
        unselectedItemColor: HexColor("0D0D0D"),
        onTap: (int index) {
          onItemTapped(index);
          selectedIndex.value = index;
        },
      ),
    );
  }

  void onItemTapped(int index) {
    if (index == 0) {
      MainNavigation.navigateToRoute(MainNavigation.clientHomePageRoute);
    }

    if (index == 1) {
      MainNavigation.navigateToRoute(MainNavigation.transporterRoute);
    }
    if (index == 2) {
      MainNavigation.navigateToRoute(MainNavigation.clientHistoryPageRoute);
    }

    if (index == 3) {
      MainNavigation.navigateToRoute(MainNavigation.clientprofilePageRoute);
    }
  }
}

class LandAndTruckNavBar extends StatelessWidget {
  const LandAndTruckNavBar({super.key, required this.selectedIndex});

  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BottomNavigationBar(
      backgroundColor: AppColors.bottomNavColor,
      selectedLabelStyle: GoogleFonts.actor(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.iconColor,
      ),
      unselectedLabelStyle: GoogleFonts.ptSerif(
        fontSize: 14,
        fontWeight: FontWeight.w200,
        color: AppColors.darkTextColor,
      ),
      unselectedIconTheme: IconThemeData(color: AppColors.darkTextColor),
      items: const [
        BottomNavigationBarItem(
          label: 'Requests',
          icon: Icon(Icons.notification_important),
        ),
        BottomNavigationBarItem(
          label: 'Posts',
          icon: Icon(Icons.house_rounded),
        ),
        BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person)),
      ],
      currentIndex: selectedIndex.value,
      fixedColor: AppColors.iconColor,
      unselectedItemColor: HexColor("0D0D0D"),
      onTap: (int index) {
        onItemTapped(index);
        selectedIndex.value = index;
      },
    );
  }

  void onItemTapped(int index) {
    if (index == 0) {
      MainNavigation.navigateToRoute(MainNavigation.requestsRoute);
    }

    if (index == 1) {
      MainNavigation.navigateToRoute(MainNavigation.myTrucksListRoute);
    }

    if (index == 2) {
      MainNavigation.navigateToRoute(MainNavigation.landAndTruckProfileRoute);
    }
  }
}
