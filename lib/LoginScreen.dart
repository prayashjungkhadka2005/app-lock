import 'package:bbl_security/UserLogin.dart';
import 'package:flutter/material.dart';
import 'OtpScreen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  Country? _selectedCountry;

  bool _isHovering = false;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;
  String? _countryErrorMessage;

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

  void registerUser() async {
    int emptyFieldsCount = 0;

    setState(() {
      _emailErrorMessage =
          emailController.text.isEmpty ? 'Email cannot be empty' : null;
      _passwordErrorMessage =
          passwordController.text.isEmpty ? 'Password cannot be empty' : null;
      _confirmPasswordErrorMessage = confirmPasswordController.text.isEmpty
          ? 'Confirm Password cannot be empty'
          : null;
      _countryErrorMessage =
          _selectedCountry == null ? 'Country cannot be empty' : null;

      // Count the number of empty fields
      emptyFieldsCount = [
        _emailErrorMessage,
        _passwordErrorMessage,
        _confirmPasswordErrorMessage,
        _countryErrorMessage
      ].where((message) => message != null).length;
    });

    // If more than one field is empty, show a toast message and clear individual errors
    if (emptyFieldsCount > 1) {
      setState(() {
        _emailErrorMessage = null;
        _passwordErrorMessage = null;
        _confirmPasswordErrorMessage = null;
        _countryErrorMessage = null;
      });
      _showToast(context, "Please fill up required fields", isSuccess: false);
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    // If only one field is empty, show the error message for that field only
    if (emptyFieldsCount == 1) {
      return;
    }

    // Validate email format
    if (!EmailValidator.validate(emailController.text)) {
      setState(() {
        _emailErrorMessage = 'Enter a valid email';
      });
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _confirmPasswordErrorMessage = 'Passwords do not match';
      });
      return;
    }

    // Proceed with the registration
    final Uri url = Uri.parse('http://192.168.1.79:3000/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'country': _selectedCountry!.name,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201 && mounted) {
        _cancelCurrentToast(); // Cancel any active toast
        await Future.delayed(
            const Duration(seconds: 1)); // Wait for the toast to be shown

        // Ensure the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                email: emailController.text,
                country: _selectedCountry!.name,
                password: passwordController.text,
              ),
            ),
          );
        }
      } else {
        final responseBody = jsonDecode(response.body);
        _showToast(context, responseBody['message'], isSuccess: false);
      }
    } on SocketException {
      _showToast(context, "No Internet Connection", isSuccess: false);
    } catch (e) {
      _showToast(context, 'Failed to register user: $e', isSuccess: false);
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
                  "Signup Now",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "One step away to make your mobile secure",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country;
                          _countryErrorMessage = null;
                        });
                      },
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 55, // Match height with other input fields
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _countryErrorMessage != null
                                ? Colors.red
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                if (_selectedCountry == null)
                                  const Icon(Icons.public)
                                else
                                  Text(
                                    _selectedCountry!.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry == null
                                      ? 'Select Country'
                                      : _selectedCountry!.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _countryErrorMessage != null
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      if (_countryErrorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 10.0),
                          child: Text(
                            _countryErrorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Email',
                    errorText: _emailErrorMessage,
                    errorStyle:
                        const TextStyle(fontSize: 12), // Smaller error text
                  ),
                ),
                const SizedBox(height: 16),
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
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000E26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
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
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 14),
                    ),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _isHovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _isHovering = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          _cancelCurrentToast();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserLogin()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: const Color(0xFF000E26),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: _isHovering
                                ? TextDecoration.underline
                                : TextDecoration.none,
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
