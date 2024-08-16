import 'package:bbl_security/App.dart';
import 'package:bbl_security/AppsScreen.dart';
import 'package:bbl_security/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_screen.dart';
import 'splash.dart';
import 'services/init.dart';
import 'package:bbl_security/DisclamerScreen.dart';
import 'package:bbl_security/pin_screen.dart';
import 'package:bbl_security/AppsScreen.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String useremail = 'aaaa';
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
      ],
      navigatorKey: navigatorKey,
    );
  }
}
