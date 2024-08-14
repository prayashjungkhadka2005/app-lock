import 'package:flutter/material.dart';
import 'fingerprint_screen.dart';
import 'patterns_screen.dart';
import 'pin_screen.dart';
import 'face_auth_page.dart';

class MyApp extends StatelessWidget {
  final String useremail;

  MyApp({super.key, required this.useremail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LockOption(useremail: useremail),
    );
  }
}

class LockOption extends StatefulWidget {
  final String useremail;

  const LockOption({Key? key, required this.useremail}) : super(key: key);

  @override
  _LockOptionState createState() => _LockOptionState();
}

class _LockOptionState extends State<LockOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              "Choose Your Preferred Lock Method",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000E26),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OptionButton(
              icon: Icons.pin,
              text: 'PIN',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PinScreen(useremail: widget.useremail)),
              ),
            ),
            OptionButton(
              icon: Icons.face,
              text: 'Face Lock',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FaceAuthPage(useremail: widget.useremail)),
              ),
            ),
            OptionButton(
              icon: Icons.fingerprint,
              text: 'Fingerprint',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FingerprintAuthPage()),
              ),
            ),
            OptionButton(
              icon: Icons.pattern,
              text: 'Pattern',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PatternsScreen(useremail: widget.useremail)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const OptionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF000E26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
