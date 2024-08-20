import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import 'RecoveryOtpScreen.dart';

class SecurityQueScreen extends StatefulWidget {
  final String email;
  final String country;
  final String password;

  const SecurityQueScreen({
    Key? key,
    required this.email,
    required this.country,
    required this.password,
  }) : super(key: key);

  @override
  _SecurityQueScreenState createState() => _SecurityQueScreenState();
}

class _SecurityQueScreenState extends State<SecurityQueScreen> {
  TextEditingController answer1Controller = TextEditingController();
  TextEditingController answer2Controller = TextEditingController();
  TextEditingController recoveryEmailController = TextEditingController();

  String? _question1ErrorMessage;
  String? _question2ErrorMessage;
  String? _question3ErrorMessage;

  FToast? _currentToast;

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _cancelCurrentToast() {
    _currentToast?.removeCustomToast();
  }

  void submitSecurityQuestions() async {
    setState(() {
      _question1ErrorMessage =
          answer1Controller.text.isEmpty ? 'This field cannot be empty' : null;
      _question2ErrorMessage =
          answer2Controller.text.isEmpty ? 'This field cannot be empty' : null;
      _question3ErrorMessage = recoveryEmailController.text.isEmpty
          ? 'This field cannot be empty'
          : !EmailValidator.validate(recoveryEmailController.text)
              ? 'Enter a valid email'
              : null;
    });

    int emptyFieldsCount = [
      _question1ErrorMessage,
      _question2ErrorMessage,
      _question3ErrorMessage
    ].where((message) => message != null).length;

    if (emptyFieldsCount > 1) {
      setState(() {
        _question1ErrorMessage = null;
        _question2ErrorMessage = null;
        _question3ErrorMessage = null;
      });
      _cancelCurrentToast();
      showToast(context, "Enter required security questions", isSuccess: false);
      return;
    }

    if (_question1ErrorMessage != null ||
        _question2ErrorMessage != null ||
        _question3ErrorMessage != null) {
      return;
    }

    final String qns1 = "What is your first pet name?";
    final String qns2 = "Where were you born?";
    final String ans1 = answer1Controller.text;
    final String ans2 = answer2Controller.text;
    final String recoveryEmail = recoveryEmailController.text;

    final Uri url = Uri.parse('http://192.168.1.79:3000/recoveryMail');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'useremail': widget.email,
          'recoveryemail': recoveryEmail,
          'qns1': qns1,
          'qns2': qns2,
          'ans1': ans1,
          'ans2': ans2,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && mounted) {
        showToast(context, 'Security questions saved successfully',
            isSuccess: true);

        await Future.delayed(const Duration(seconds: 1));

        _cancelCurrentToast();

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecoveryOtpScreen(
              useremail: widget.email,
              recoveryemail: recoveryEmail,
              qns1: qns1,
              qns2: qns2,
              ans1: ans1,
              ans2: ans2,
              country: widget.country,
              password: widget.password,
            ),
          ),
        );
      } else {
        showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      showToast(context, 'Failed to send recovery email: $e', isSuccess: false);
    }
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
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Setup Security Questions",
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "One step away to secure your account",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "1. What is your first pet name?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: answer1Controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter your answer',
                    errorText: _question1ErrorMessage,
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "2. Where were you born?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: answer2Controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter your answer',
                    errorText: _question2ErrorMessage,
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "3. Recovery Email?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: recoveryEmailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Enter your recovery email',
                    errorText: _question3ErrorMessage,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: submitSecurityQuestions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000E26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Let's Go",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showToast(BuildContext context, String message,
    {required bool isSuccess}) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast
      .removeCustomToast(); 
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
