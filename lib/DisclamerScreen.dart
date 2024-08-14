import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'LoginScreen.dart';
import 'LockOption.dart';

class DisclamerScreen extends StatefulWidget {
  final String useremail;

  const DisclamerScreen({Key? key, required this.useremail}) : super(key: key);

  @override
  _DisclamerScreenState createState() => _DisclamerScreenState();
}

class _DisclamerScreenState extends State<DisclamerScreen> {
  FToast? _currentToast;

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _verifyTermsAndConditions() async {
    final url =
        'http://192.168.1.79:3000/disclaimer'; // Ensure this URL is correct
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': widget.useremail, 'call': 'calling'}),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _showToast(responseBody['message'], isSuccess: true);
        Future.delayed(const Duration(seconds: 1), () {
          _currentToast!.removeCustomToast();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LockOption(useremail: widget.useremail)),
          );
        });
      } else {
        _showToast(responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _showToast('An error occurred: $e', isSuccess: false);
    }
  }

  void _declineTermsAndConditions() {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blurred Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            // Dialog Box
            Dialog(
              backgroundColor:
                  Color(0xFF000E26), // Match the background color of the screen
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.85, // Slightly wider dialog
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF000E26), // Match the screen background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Already leaving?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "By confirming, the signup process will be exited. Are you sure you want to decline?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width:
                          double.infinity, // Makes the button take full width
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Yes, Opt out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "No, I am staying",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message, {required bool isSuccess}) {
    _currentToast!
        .removeCustomToast(); // Cancel any existing toast before showing a new one
    _currentToast!.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: isSuccess ? Colors.green : Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8.0),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
      toastDuration: const Duration(seconds: 1),
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 30),
                const Text(
                  "Disclaimer",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "BBL Security is designed to enhance the privacy and security of your apps and personal information. While we strive to provide robust protection, we cannot guarantee absolute security against all possible threats. Users are responsible for maintaining the confidentiality of their passwords and other access credentials. BBL Security is not liable for any data loss or unauthorized access resulting from user negligence or misuse of the app. By using this app, you agree to these terms and conditions.",
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _declineTermsAndConditions,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  10), // Reduced padding for shorter height
                        ),
                        child: const Text(
                          "Decline",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _verifyTermsAndConditions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000E26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical:
                                  10), // Reduced padding for shorter height
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
