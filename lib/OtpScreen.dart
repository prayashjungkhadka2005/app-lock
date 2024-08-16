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
  FToast? _currentToast;

  final ValueNotifier<String> otpCode = ValueNotifier<String>('');

  final Uri verifyOtpUrl = Uri.parse('http://192.168.1.79:3000/verifyotp');
  final Uri resendOtpUrl = Uri.parse('http://192.168.1.79:3000/resendotp');

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _cancelCurrentToast() {
    _currentToast?.removeCustomToast();
  }

  void _submitOtp() async {
    if (otpCode.value.length != 6) {
      _cancelCurrentToast();
      _logger.warning('OTP code must be 6 digits long');
      _showToast(context, 'Please enter a 6-digit OTP', isSuccess: false);
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
        _cancelCurrentToast();
        _logger.info('OTP verified successfully');
        _showToast(context, responseBody['message'], isSuccess: true);

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
        _cancelCurrentToast();

        _logger.warning('Failed to verify OTP: ${responseBody['message']}');
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _cancelCurrentToast();

      _logger.severe('Error during OTP verification: $e');
      _showToast(context, 'Error during OTP verification', isSuccess: false);
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
        _cancelCurrentToast();

        _logger.info('OTP resent successfully');
        _showToast(context, responseBody['message'], isSuccess: true);
      } else {
        _cancelCurrentToast();

        _logger.warning('Failed to resend OTP: ${responseBody['message']}');
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _cancelCurrentToast();

      _logger.severe('Error during OTP resend: $e');
      _showToast(context, 'Error during OTP resend', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDDEE1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF000E26)),
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
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 25),
                const Text(
                  "OTP Verification",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter the OTP sent to your email",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onChanged: (value) {
                    otpCode.value = value;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 45,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        "Resend OTP Code",
                        style: TextStyle(
                          color: Color(0xFF000E26),
                          fontSize: 14,
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

// Top-level function to show toast
void _showToast(BuildContext context, String message,
    {required bool isSuccess}) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast
      .removeCustomToast(); // Cancel any existing toast before showing a new one
  fToast.showToast(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: isSuccess ? Colors.green : Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    ),
    toastDuration: const Duration(seconds: 1),
    gravity: ToastGravity.BOTTOM,
  );
}

// Top-level function to cancel toast
void _cancelCurrentToast() {
  FToast().removeCustomToast();
}
