import 'dart:ui';
import 'package:brickapp/custom_widgets/custom_expansion_list.dart';
import 'package:brickapp/custom_widgets/profile_transparent_widget.dart';
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/pages/onboardingPages/login.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../utils/app_images.dart' as backImg;

class ClientProfile extends ConsumerStatefulWidget {
  ClientProfile({super.key});
  @override
  ConsumerState<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends ConsumerState<ClientProfile> {
  @override
  void initState() {
    super.initState();
    // Ensure auto-refresh is active when widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(userProvider).isLoggedIn) {
        ref.read(userProvider.notifier).refreshProfile();
      }
    });
  }

  final double _sigmax = 4.0;
  final double _sigmay = 4.0;
  final TextStyle style = GoogleFonts.oxygen(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: HexColor("#050607"),
  );

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final screenSize = MediaQuery.of(context).size.width;
    // Determine what to display
    AccountType displayAccountType = userState.accountType!;
    bool showUpgradedFeatures = false;

    // If they upgraded but not verified yet, still show as client
    if (userState.isVerified != true) {
      displayAccountType = AccountType.client;
    } else {
      displayAccountType = userState.accountType!;
      showUpgradedFeatures = true;
    }
    if (userState.isSuspended == true &&
        (userState.accountType == AccountType.property_manager ||
            userState.accountType == AccountType.service_provider)) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Account Suspended',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your listings have been temporarily hidden from clients.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                if (userState.suspensionReason != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Reason:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          userState.suspensionReason!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Please contact support if you believe this is a mistake.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backImg.AppImages.backImg),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _sigmax, sigmaY: _sigmay),
                  child: Container(color: Colors.transparent),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(height: screenSize / 5),
                      Container(
                        alignment: Alignment.topCenter,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.deepOrange,
                          backgroundImage:
                              userState.avatar != null
                                  ? NetworkImage(
                                    userState.avatar!.startsWith('http')
                                        ? userState.avatar!
                                        : '${AppUrls.baseUrl}/${userState.avatar}',
                                  )
                                  : const NetworkImage(
                                    'https://miro.medium.com/v2/resize:fit:1079/1*G6bWZ2AzAAPVsl86NU-2bQ.png',
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userState.fullName ?? '',
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userState.phone ?? '',
                        style: GoogleFonts.actor(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightTextColor,
                        ),
                      ),

                      SizedBox(height: screenSize / 10),

                      // FIXED: Compare the accountType directly instead of using toString()
                      if (displayAccountType == AccountType.property_manager &&
                          showUpgradedFeatures)
                        Column(
                          children: [
                            ExpansionTileWidget(
                              icon: Icons.document_scanner,
                              text: "User ID Info",
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Name", style: style),
                                ),
                                Text(userState.fullName ?? '', style: style),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Phone Number", style: style),
                                ),
                                Text(userState.phone ?? '', style: style),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Gender", style: style),
                                ),
                                Text(userState.gender ?? '', style: style),
                              ],
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Card(
                                color: HexColor("FFFFFF").withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    MainNavigation.navigateToRoute(
                                      MainNavigation.PManagerSettingsRoute,
                                    );
                                  },
                                  leading: Icon(
                                    Icons.settings,
                                    color: AppColors.iconColor,
                                  ),
                                  title: Text(
                                    "Settings",
                                    style: GoogleFonts.actor(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ProfileTransparentButton(
                              buttonDescription: "Add Post",
                              icon: Icons.add,
                              onTap: () {
                                MainNavigation.navigateToRoute(
                                  MainNavigation.addPostRoute,
                                );
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Card(
                                color: HexColor("FFFFFF").withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    MainNavigation.navigateToRoute(
                                      MainNavigation.myPropertyPosts,
                                    );
                                  },
                                  leading: Icon(
                                    Icons.list,
                                    color: AppColors.iconColor,
                                  ),
                                  title: Text(
                                    "Your Posts",
                                    style: GoogleFonts.actor(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (displayAccountType ==
                              AccountType.service_provider &&
                          showUpgradedFeatures) // FIXED: Direct comparison
                        Column(
                          children: [
                            ExpansionTileWidget(
                              icon: Icons.document_scanner,
                              text: "User ID Info",
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Name", style: style),
                                ),
                                Text(userState.fullName ?? '', style: style),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Phone Number", style: style),
                                ),
                                Text(userState.phone ?? '', style: style),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Gender", style: style),
                                ),
                                Text(userState.gender ?? '', style: style),
                              ],
                            ),
                            ProfileTransparentButton(
                              buttonDescription: "Post Vehicle",
                              icon: Icons.add,
                              onTap: () {
                                MainNavigation.navigateToRoute(
                                  MainNavigation.postTruckRoute,
                                );
                              },
                            ),
                            ProfileTransparentButton(
                              buttonDescription: "My Posted Vehicles",
                              icon: Icons.list,
                              onTap: () {
                                MainNavigation.navigateToRoute(
                                  MainNavigation.myTrucksListRoute,
                                );
                              },
                            ),
                          ],
                        ),

                      // FIXED: Simplified the condition
                      if (displayAccountType == AccountType.client &&
                          showUpgradedFeatures)
                        Container(
                          alignment: Alignment.center,
                          child: Card(
                            color: HexColor("FFFFFF").withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () {
                                MainNavigation.navigateToRoute(
                                  MainNavigation.upgradeProfileRoute,
                                );
                              },
                              leading: Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.iconColor,
                              ),
                              title: Text(
                                "Upgrade Profile",
                                style: GoogleFonts.actor(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Common widgets for all account types
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              if (displayAccountType ==
                                      AccountType.property_manager &&
                                  showUpgradedFeatures) {
                                MainNavigation.navigateToRoute(
                                  MainNavigation
                                      .requestsForPropertyManagerRoute,
                                );
                              } else if (displayAccountType ==
                                      AccountType.service_provider &&
                                  showUpgradedFeatures) {
                                MainNavigation.navigateToRoute(
                                  MainNavigation.requestsForSProviderRoute,
                                );
                              } else {
                                // client
                                MainNavigation.navigateToRoute(
                                  MainNavigation.requestsForClientRoute,
                                );
                              }
                            },
                            leading: Icon(
                              Icons.request_page_outlined,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Requests",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.mainFavouriteDisplayRoute,
                              );
                            },
                            leading: Icon(
                              Icons.favorite,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "View Favourites",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              MainNavigation.navigateToRoute(
                                MainNavigation.clientEditProfilePageRoute,
                              );
                            },
                            leading: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Edit Profile",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        child: Card(
                          color: HexColor("FFFFFF").withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              _showLogoutConfirmationDialog(context);
                            },
                            leading: Icon(
                              Icons.logout_outlined,
                              color: AppColors.iconColor,
                            ),
                            title: Text(
                              "Logout",
                              style: GoogleFonts.actor(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.deepOrange),
              const SizedBox(width: 8),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Clear any user data or state if needed
    // ref.read(userProfileProvider.notifier).reset();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      (route) => false,
    );
  }
}
