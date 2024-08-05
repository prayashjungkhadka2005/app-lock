// import 'package:bbl_security/services/init.dart';
// import 'package:bbl_security/splash.dart';
// import 'package:flutter/material.dart';

// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initialize();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       home: const SplashPage(),
//     );
//   }
// }
import 'package:bbl_security/services/init.dart';
import 'package:bbl_security/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_screen.dart'; // Import your authentication screen

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  // Initialize MethodChannel after initialization
  MyApp.platform.setMethodCallHandler((call) async {
    if (call.method == "showAuthScreen") {
      navigatorKey.currentState?.pushReplacementNamed('/auth');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Define MethodChannel as static so it can be accessed in main()
  static const platform = MethodChannel('com.example.gobbl/foregroundService');

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/auth':
            return MaterialPageRoute(builder: (_) => AuthScreen());
          default:
            return null; // Return null or a default route if necessary
        }
      },
    );
  }
}
