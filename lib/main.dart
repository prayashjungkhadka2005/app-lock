import 'package:bbl_security/AppsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_screen.dart';
import 'splash.dart';
import 'services/init.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Locker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashPage()), // Splash screen
        GetPage(name: '/auth', page: () => AuthScreen()), // Auth screen
      ],
      navigatorKey: navigatorKey,
    );
  }
}
