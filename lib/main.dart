import 'package:brickapp/pages/onboardingPages/login.dart';
import 'package:brickapp/utils/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

late TabController tabController;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brick App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        return BaseNavigation.onGenerateRoute(settings);
      },
      navigatorKey: NavigatorKeys.baseKey,
      home: LoginPage(),
    );
  }
}
