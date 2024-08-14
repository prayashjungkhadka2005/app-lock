import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'SecurityQueScreen.dart';

final Logger _logger = Logger('OtpScreen');

class OtpScreen extends StatefulWidget {
  final String email;
  final String country;
  final String password;

  const OtpScreen({
    super.key,
    required this.email,
    required this.country,
    required this.password,
  });

  @override
  OtpScreenState createState() => OtpScreenState();
}

class OtpScreenState extends State<OtpScreen> {
  final ValueNotifier<String> otpCode = ValueNotifier<String>('');

  FToast? _currentToast;

  final Uri verifyOtpUrl = Uri.parse('http://192.168.1.79:3000/verifyotp');
  final Uri resendOtpUrl = Uri.parse('http://192.168.1.79:3000/resendotp');

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _submitOtp() async {
    if (otpCode.value.length != 6) {
      _logger.warning('OTP code must be 6 digits long');
      _showToast('Please enter a 6-digit OTP', isSuccess: false);
      return;
    }

    try {
      final response = await http.post(
        verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': otpCode.value,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _logger.info('OTP verified successfully');
        _showToast(responseBody['message'], isSuccess: true);

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecurityQueScreen(
              email: widget.email,
              country: widget.country,
              password: widget.password,
            ),
          ),
        );
      } else {
        _logger.warning('Failed to verify OTP: ${responseBody['message']}');
        _showToast(responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _logger.severe('Error during OTP verification: $e');
      _showToast('Error during OTP verification', isSuccess: false);
    }
  }

  void _resendOtp() async {
    try {
      final response = await http.post(
        resendOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _logger.info('OTP resent successfully');
        _showToast(responseBody['message'], isSuccess: true);
      } else {
        _logger.warning('Failed to resend OTP: ${responseBody['message']}');
        _showToast(responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _logger.severe('Error during OTP resend: $e');
      _showToast('Error during OTP resend', isSuccess: false);
    }
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
            SizedBox(width: 8.0),
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
      toastDuration: Duration(seconds: 1),
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDDEE1), // Pin box background color
        borderRadius: BorderRadius.circular(12), // Consistent with login screen
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF000E26)), // Border color
      ),
    );

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
                  "OTP Verification",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000E26)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "One step away to secure your account",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onChanged: (value) {
                    otpCode.value = value;
                  },
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000E26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Verify Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        "Resend OTP Code",
                        style: TextStyle(
                          color: Color(0xFF000E26),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
