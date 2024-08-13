import 'package:bbl_security/AppsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert'; // Import for encoding to base64
import 'package:http/http.dart' as http; // Import for HTTP requests

class AuthService {
  static final LocalAuthentication _localAuthentication = LocalAuthentication();

  static Future<bool> authenticateUser() async {
    bool isAuthenticated = false;
    try {
      bool isBiometricSupported =
          await _localAuthentication.isDeviceSupported();
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      if (isBiometricSupported && canCheckBiometrics) {
        isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: 'Scan your biometrics to authenticate',
        );
      }
    } on PlatformException catch (e) {
      print("Error during authentication: $e");
    }
    return isAuthenticated;
  }

  static Future<String> getAuthType() async {
    List<BiometricType> availableBiometrics =
        await _localAuthentication.getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else {
      return 'Unknown';
    }
  }
}

class FaceAuthPage extends StatefulWidget {
  final String useremail;

  FaceAuthPage({Key? key, required this.useremail}) : super(key: key);

  @override
  _FaceAuthPageState createState() => _FaceAuthPageState();
}

class _FaceAuthPageState extends State<FaceAuthPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _authorized = 'Not Authorized';
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _statusMessage = _canCheckBiometrics
            ? 'Biometric authentication available'
            : 'No biometric authentication available';
      });
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
        _statusMessage = 'Error checking biometrics';
      });
      print("Error checking biometrics: $e");
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      if (_canCheckBiometrics) {
        authenticated = await AuthService.authenticateUser();
      }
    } catch (e) {
      print("Error during authentication: $e");
      setState(() {
        _authorized = 'Authentication error';
        _statusMessage = 'Authentication error';
      });
      return;
    }

    if (authenticated) {
      String token = _generateToken();
      print("Generated Token: $token");

      // Get the authentication type
      String authType = await AuthService.getAuthType();

      final response = await http.post(
        Uri.parse('http://192.168.1.79:3000/setbiometric'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'biometricToken': token,
          'useremail': widget.useremail,
          'authType': authType,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _authorized = 'Authorized';
          _statusMessage = 'Biometric authentication successful';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication setup successful!'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppsScreen()),
        );
      } else {
        setState(() {
          _authorized = 'Authorization failed';
          _statusMessage = 'Failed to authenticate with API';
        });
        print('Failed to authenticate with API: ${response.statusCode}');
      }
    } else {
      setState(() {
        _authorized = 'Not Authorized';
        _statusMessage = 'Authentication failed';
      });
    }
    print("Authentication result: $authenticated");
  }

  String _generateToken() {
    final bytes = utf8.encode(DateTime.now().toString());
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 253, 253, 253),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 10),
              Text(
                'Setup biometric authentication',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000E26),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (_canCheckBiometrics) {
                    await _authenticate();
                  } else {
                    setState(() {
                      _authorized = 'No biometric authentication available';
                      _statusMessage = 'No biometric authentication available';
                    });
                  }
                },
                child: SvgPicture.asset(
                  'assets/faceauth.svg',
                  width: 200,
                  height: 200,
                  color: Color(0xFF00358C),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Status: $_statusMessage',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
