import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'DisclamerScreen.dart';

final Logger _logger = Logger('RecoveryOtpScreen');

class RecoveryOtpScreen extends StatefulWidget {
  final String useremail;
  final String recoveryemail;
  final String qns1;
  final String qns2;
  final String ans1;
  final String ans2;
  final String country;
  final String password;

  const RecoveryOtpScreen({
    super.key,
    required this.useremail,
    required this.recoveryemail,
    required this.qns1,
    required this.qns2,
    required this.ans1,
    required this.ans2,
    required this.country,
    required this.password,
  });

  @override
  _RecoveryOtpScreenState createState() => _RecoveryOtpScreenState();
}

class _RecoveryOtpScreenState extends State<RecoveryOtpScreen> {
  String otpCode = '';
  FToast? _currentToast;

  final Uri verifyOtpUrl = Uri.parse('http://192.168.1.79:3000/setSecurity');
  final Uri resendOtpUrl =
      Uri.parse('http://192.168.1.79:3000/resendRecoveryOtp');

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _submitOtp() async {
    if (otpCode.length != 6) {
      _logger.warning('OTP code must be 6 digits long');
      _showToast('Please enter a 6-digit OTP', isSuccess: false);
      return;
    }

    try {
      final response = await http.post(
        verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'useremail': widget.useremail,
          'recoveryemail': widget.recoveryemail,
          'qns1': widget.qns1,
          'qns2': widget.qns2,
          'ans1': widget.ans1,
          'ans2': widget.ans2,
          'otp': otpCode,
          'country': widget.country,
          'password': widget.password,
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
            builder: (context) => DisclamerScreen(useremail: widget.useremail),
          ),
        );
      } else {
        _logger.warning(responseBody['message']);
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
          'recoveryemail': widget.recoveryemail,
          'useremail': widget.useremail,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _logger.info('OTP resent successfully');
        _showToast(responseBody['message'], isSuccess: true);
      } else {
        _logger.warning(responseBody['message']);
        _showToast(responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _logger.severe('$e');
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
        borderRadius: BorderRadius.circular(12),
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
                  "Recovery OTP Verification",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    "Enter the recovery OTP sent to your email.",
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  onChanged: (value) {
                    otpCode = value;
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
                      "Verify Recovery Email",
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
