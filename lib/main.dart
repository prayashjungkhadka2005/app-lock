// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'auth_screen.dart';
// import 'splash.dart';
// import 'services/init.dart';

// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await initialize();

//   MyApp.platform.setMethodCallHandler((call) async {
//     if (call.method == "showAuthScreen") {
//       print("MethodChannel: showAuthScreen called");
//       // Trigger native code to show AuthActivity
//       const platform = MethodChannel('flutter.native/helper');
//       await platform.invokeMethod('showAuthActivity');
//     }
//   });

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   static const platform = MethodChannel('com.example.gobbl/foregroundService');

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'App Locker',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       getPages: [
//         GetPage(name: '/', page: () => SplashPage()), // Splash screen
//         GetPage(name: '/auth', page: () => AuthScreen()), // Auth screen
//       ],
//       navigatorKey: navigatorKey,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'auth_screen.dart';
import 'splash.dart';
import 'services/init.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();

  MyApp.platform.setMethodCallHandler((call) async {
    if (call.method == "showAuthScreen") {
      print("MethodChannel: showAuthScreen called");
      // Trigger native code to show AuthActivity
      const platform = MethodChannel('flutter.native/helper');
      await platform.invokeMethod('showAuthActivity');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('com.example.gobbl/foregroundService');

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
