import 'dart:convert';
import 'package:bbl_security/UserLogin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class NewPassword extends StatefulWidget {
  final String email;

  const NewPassword({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _NewPasswordState createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;

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

  void submitNewPassword() async {
    int emptyFieldsCount = 0;

    setState(() {
      _passwordErrorMessage =
          passwordController.text.isEmpty ? 'Password cannot be empty' : null;
      _confirmPasswordErrorMessage = confirmPasswordController.text.isEmpty
          ? 'Confirm Password cannot be empty'
          : null;

      // Count the number of empty fields
      emptyFieldsCount = [
        _passwordErrorMessage,
        _confirmPasswordErrorMessage,
      ].where((message) => message != null).length;
    });

    // If more than one field is empty, show a toast message and clear individual errors
    if (emptyFieldsCount > 1) {
      setState(() {
        _passwordErrorMessage = null;
        _confirmPasswordErrorMessage = null;
      });
      _showToast(context, "Please fill up required fields", isSuccess: false);
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    // If only one field is empty, show the error message for that field only
    if (emptyFieldsCount == 1) {
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _confirmPasswordErrorMessage = 'Passwords do not match';
      });
      return;
    }

    // Proceed with updating the password
    final String newPassword = passwordController.text;

    final Uri url = Uri.parse('http://192.168.1.79:3000/newPassword');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'password': newPassword,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201 && mounted) {
        _cancelCurrentToast(); // Cancel any active toast
        _showToast(context, 'Password updated successfully', isSuccess: true);

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        _cancelCurrentToast();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserLogin(),
          ),
        );
      } else {
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } catch (e) {
      _showToast(context, 'Failed to update password: $e', isSuccess: false);
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
                  "Set Your New Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create a strong and secure password",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Password',
                    errorText: _passwordErrorMessage,
                    errorStyle:
                        const TextStyle(fontSize: 12), // Smaller error text
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Confirm Password',
                    errorText: _confirmPasswordErrorMessage,
                    errorStyle:
                        const TextStyle(fontSize: 12), // Smaller error text
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: submitNewPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000E26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Update Password",
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
