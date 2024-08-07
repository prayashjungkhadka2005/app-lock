// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';

// // // GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// // // void main() {
// // //   runApp(MyApp());
// // // }

// // // class MyApp extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       navigatorKey: navigatorKey,
// // //       initialRoute: '/',
// // //       routes: {
// // //         '/': (context) => AuthScreen(),
// // //         '/home': (context) => HomeScreen(), // Define your HomeScreen
// // //       },
// // //     );
// // //   }
// // // }

// // // class AuthScreen extends StatefulWidget {
// // //   @override
// // //   _AuthScreenState createState() => _AuthScreenState();
// // // }

// // // class _AuthScreenState extends State<AuthScreen> {
// // //   static const platform = MethodChannel('com.example.gobbl/foregroundService');

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _checkAuthenticationStatus();
// // //     platform.setMethodCallHandler((call) async {
// // //       if (call.method == "showAuthScreen") {
// // //         navigatorKey.currentState?.pushReplacementNamed('/auth');
// // //       }
// // //     });
// // //   }

// // //   Future<void> _checkAuthenticationStatus() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final authenticated = prefs.getBool('authenticated') ?? false;
// // //     if (authenticated) {
// // //       Navigator.of(context).pushReplacementNamed('/home'); // Or your desired route
// // //     }
// // //   }

// // //   void _authenticate() async {
// // //     // Perform your authentication logic here
// // //     final prefs = await SharedPreferences.getInstance();
// // //     await prefs.setBool('authenticated', true);
// // //     Navigator.of(context).pushReplacementNamed('/home'); // Or your desired route
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Authentication')),
// // //       body: Center(
// // //         child: ElevatedButton(
// // //           onPressed: _authenticate,
// // //           child: Text('Authenticate'),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // class HomeScreen extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Home')),
// // //       body: Center(child: Text('Welcome to the Home Screen')),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:device_apps/device_apps.dart';

// // class AuthScreen extends StatefulWidget {
// //   @override
// //   _AuthScreenState createState() => _AuthScreenState();
// // }

// // class _AuthScreenState extends State<AuthScreen> {
// //   static const platform = MethodChannel('com.example.gobbl/foregroundService');
// //   String? packageName;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkAuthenticationStatus();
// //     platform.setMethodCallHandler((call) async {
// //       if (call.method == "showAuthScreen") {
// //         Navigator.of(context).pushReplacement(MaterialPageRoute(
// //           builder: (context) => AuthScreen(),
// //         ));
// //       }
// //     });

// //     // Retrieve the package name from the arguments
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final args = ModalRoute.of(context)!.settings.arguments as Map?;
// //       packageName = args?['packageName'] as String?;
// //     });
// //   }

// //   Future<void> _checkAuthenticationStatus() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final authenticated = prefs.getBool('authenticated') ?? false;
// //     if (authenticated) {
// //       if (packageName != null) {
// //         // Open the locked app
// //         DeviceApps.openApp(packageName!);
// //       }
// //       Navigator.of(context).pushReplacement(MaterialPageRoute(
// //         builder: (context) => HomeScreen(),
// //       ));
// //     }
// //   }

// //   void _authenticate() async {
// //     // Perform your authentication logic here
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setBool('authenticated', true);
// //     if (packageName != null) {
// //       // Open the locked app
// //       DeviceApps.openApp(packageName!);
// //     }
// //     Navigator.of(context).pushReplacement(MaterialPageRoute(
// //       builder: (context) => HomeScreen(),
// //     ));
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Authentication')),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: _authenticate,
// //           child: Text('Authenticate'),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class HomeScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Home')),
// //       body: Center(child: Text('Welcome to the Home Screen')),
// //     );
// //   }
// // }
// // lib/screens/AuthScreen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class AuthScreen extends StatelessWidget {
//   final String packageName;
//   static const platform = MethodChannel('flutter.native/helper');

//   AuthScreen({required this.packageName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Authenticate')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Please authenticate to access the app.'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 // Perform authentication
//                 // bool authenticated = await authenticateUser();
//                 // if (authenticated) {
//                 await platform.invokeMethod('openApp', packageName);
//                 Navigator.pop(context, true);
//                 // } else {
//                 //   Navigator.pop(context, false);
//                 // }
//               },
//               child: Text('Authenticate'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> authenticateUser() async {
//     // Implement your authentication logic here
//     // Return true if authentication is successful, false otherwise
//     return true;
//   }
// }
// lib/screens/AuthScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatelessWidget {
  final String packageName;

  AuthScreen({required this.packageName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            const platform = MethodChannel('flutter.native/helper');
            try {
              await platform.invokeMethod('openApp', packageName);
            } on PlatformException catch (e) {
              print("Failed to open app: '${e.message}'.");
            }
            Navigator.of(context).pop();
          },
          child: Text('Authenticate'),
        ),
      ),
    );
  }
}
