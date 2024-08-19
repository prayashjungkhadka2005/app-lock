import 'dart:convert';
import 'package:bbl_security/LoginScreen.dart';
import 'package:bbl_security/NewPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'DisclamerScreen.dart';

final Logger _logger = Logger('RecoveryOtpScreen');

class ResetOtpScreen extends StatefulWidget {
  final String useremail;

  const ResetOtpScreen({
    super.key,
    required this.useremail,
  });

  @override
  _ResetOtpScreenState createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  String otpCode = '';
  FToast? _currentToast;

  final Uri verifyOtpUrl = Uri.parse('http://192.168.1.79:3000/resetOtp');
  final Uri resendOtpUrl = Uri.parse('http://192.168.1.79:3000/resendResetOtp');

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _submitOtp() async {
    _cancelCurrentToast();
    if (otpCode.length != 6) {
      _logger.warning('OTP code must be 6 digits long');
      _showToast(context, 'Please enter a 6-digit OTP', isSuccess: false);
      return;
    }

    try {
      final response = await http.post(
        verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'useremail': widget.useremail,
          'otp': otpCode,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _cancelCurrentToast();
        _logger.info('OTP verified successfully');
        _showToast(context, responseBody['message'], isSuccess: true);

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        _cancelCurrentToast();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPassword(email: widget.useremail) ,
          ),
        );
      } else {
        _cancelCurrentToast();
        _logger.warning(responseBody['message']);
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _cancelCurrentToast();
      _logger.severe('Error during OTP verification: $e');
      _showToast(context, 'Error during OTP verification', isSuccess: false);
    }
  }

  void _resendOtp() async {
    _cancelCurrentToast();
    try {
      final response = await http.post(
        resendOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'useremail': widget.useremail,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _cancelCurrentToast();
        _logger.info('OTP resent successfully');
        _showToast(context, responseBody['message'], isSuccess: true);
      } else {
        _cancelCurrentToast();
        _logger.warning(responseBody['message']);
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _cancelCurrentToast();
      _logger.severe('$e');
      _showToast(context, 'Error during OTP resend', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50, // Reduced width
      height: 55, // Reduced height
      textStyle: const TextStyle(
        fontSize: 20, // Reduced font size
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
                  width: 80, // Reduced width
                  height: 80, // Reduced height
                ),
                const SizedBox(height: 25), // Reduced space
                const Text(
                  "Reset OTP Verification",
                  style: TextStyle(
                    fontSize: 24, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0), // Reduced padding
                  child: Text(
                    "Enter the reset OTP sent to your email.",
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontWeight: FontWeight.w500,
                      fontSize: 14, // Reduced font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25), // Reduced space
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onChanged: (value) {
                    otpCode = value;
                  },
                ),
                const SizedBox(height: 40), // Reduced space
                SizedBox(
                  width: double.infinity,
                  height: 45, // Reduced height
                  child: ElevatedButton(
                    onPressed: _submitOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000E26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Verify",
                      style: TextStyle(
                        fontSize: 14, // Reduced font size
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
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        "Resend OTP Code",
                        style: TextStyle(
                          color: Color(0xFF000E26),
                          fontSize: 14, // Reduced font size
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
