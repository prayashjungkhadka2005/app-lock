import 'package:bbl_security/AppsScreen.dart';
import 'package:bbl_security/LoginScreen.dart';
import 'package:bbl_security/home.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Call the navigation after the widget has built
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "BBL Security",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(223, 4, 4, 4),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Ultimate App Lock with Premium Protection",
                style: TextStyle(
                  color: Color.fromARGB(255, 116, 114, 114),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
