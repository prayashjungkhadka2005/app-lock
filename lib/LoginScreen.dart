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

  FToast? _currentToast; // Track the active toast

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void registerUser() async {
    print("Sign Up button clicked");
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
    });

    if (_emailErrorMessage != null ||
        _passwordErrorMessage != null ||
        _confirmPasswordErrorMessage != null ||
        _countryErrorMessage != null) {
      return;
    }

    if (!EmailValidator.validate(emailController.text)) {
      setState(() {
        _emailErrorMessage = 'Enter a valid email';
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _confirmPasswordErrorMessage = 'Passwords do not match';
      });
      return;
    }

    final Uri url = Uri.parse('http://192.168.1.79:3000/signup');
    print('server is called');
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
        _cancelCurrentToast();
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
      } else {
        final responseBody = jsonDecode(response.body);
        showError(responseBody['message']);
      }
    } on SocketException {
      _showToast("No Internet Connection");
    } catch (e) {
      showError('Failed to register user: $e');
    }
  }

  void _cancelCurrentToast() {
    _currentToast!.removeCustomToast();
  }

  void _showToast(String message) {
    _cancelCurrentToast(); 
    _currentToast!.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.white, size: 20), // Smaller icon
            SizedBox(width: 8.0), // Less space between icon and text
            Text(
              message,
              style: TextStyle(
                  color: Colors.white, fontSize: 14), // Smaller text size
            ),
          ],
        ),
      ),
      toastDuration: Duration(seconds: 1),
      gravity: ToastGravity.BOTTOM,
    );
  }

  void showError(String message) {
    if (!mounted) return;
    _showToast(message);
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
                  "Signup Now",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000E26),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "One step away to make your mobile secure",
                  style: TextStyle(
                    color: Color(0xFF6C6C6C),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
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
                        height: 55,
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
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCountry == null
                                      ? 'Select Country'
                                      : _selectedCountry!.name,
                                  style: TextStyle(
                                    fontSize: 16,
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
                          padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                          child: Text(
                            _countryErrorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                      "Already have an account? ",
                      style: TextStyle(color: Color(0xFF6C6C6C), fontSize: 16),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: const Color(0xFF000E26),
                            fontSize: 16,
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

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHovering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
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
                    "Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000E26),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome back! Please login to your account.",
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be left empty';
                      } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be left empty';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle login logic here
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000E26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Login",
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
                        "Don't have an account? ",
                        style:
                            TextStyle(color: Color(0xFF6C6C6C), fontSize: 16),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: const Color(0xFF000E26),
                              fontSize: 16,
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
                  const SizedBox(height: 20),
                  Center(
                    // Centering the Forgot Password text
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF000E26),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          // Wrap content in SingleChildScrollView
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                "Forgot your password?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000E26),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Please enter your email address below. We will send you a link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6C6C6C),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000E26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Send Reset Link",
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
        ),
      ),
    );
  }
}
