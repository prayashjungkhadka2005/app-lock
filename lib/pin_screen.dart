import 'package:bbl_security/AppsScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PinScreen extends StatefulWidget {
  final String useremail;
  const PinScreen({Key? key, required this.useremail}) : super(key: key);

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String? _firstPin;
  bool _isConfirming = false;
  String _statusText = "Enter PIN to setup lock";
  List<String> _currentPin = ["", "", "", ""];
  int _pinIndex = 0;
  String? _blinkKey;
  FToast? _currentToast;

  @override
  void initState() {
    super.initState();
    _currentToast = FToast();
    _currentToast!.init(context);
  }

  void _handleKeyTap(String value) {
    setState(() {
      if (value == 'back') {
        if (_pinIndex > 0) {
          _pinIndex--;
          _currentPin[_pinIndex] = "";
        }
      } else {
        if (_pinIndex < 4) {
          _currentPin[_pinIndex] = value;
          _pinIndex++;
        }
      }

      if (_pinIndex == 4) {
        _handlePinSubmit(_currentPin.join());
      }
    });
  }

  void _handlePinSubmit(String pin) async {
    if (_isConfirming) {
      if (_firstPin == pin) {
        setState(() {
          _statusText = "PIN setup successfully!";
        });
        await _sendPinToServer(_firstPin!);
      } else {
        _showToast('Enter correct PIN', isSuccess: false);
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _isConfirming = false;
            _firstPin = null;
            _statusText = "Enter PIN to setup lock";
            _clearPin();
          });
          _currentToast!.removeCustomToast();
        });
      }
    } else {
      _firstPin = pin;
      setState(() {
        _isConfirming = true;
        _statusText = "Confirm your PIN";
        _clearPin();
      });
    }
  }

  void _clearPin() {
    setState(() {
      _currentPin = ["", "", "", ""];
      _pinIndex = 0;
    });
  }

  Future<void> _sendPinToServer(String pin) async {
    final url = 'http://192.168.1.79:3000/setPin';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'useremail': widget.useremail,
          'pin': pin,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final successMessage =
            responseBody['message'] ?? 'PIN setup successfully!';

        final prefs = await SharedPreferences.getInstance();

        bool success = await prefs.setString('user_pin', pin);
        await prefs.setBool('isPinSetupComplete', true);

        if (success) {
          if (mounted) {
            _showToast(successMessage, isSuccess: true);
            Future.delayed(const Duration(seconds: 2), () {
              _currentToast!.removeCustomToast();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppsScreen()),
              );
            });
          }
        } else {
          print('Failed to commit the PIN to SharedPreferences');
        }
      } else {
        _showToast('Failed to send PIN to server.', isSuccess: false);
      }
    } catch (e) {
      _showToast('An error occurred.', isSuccess: false);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          const Image(
            image: AssetImage('assets/logo.png'),
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 20),
          Text(
            _statusText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000E26),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _currentPin[index].isNotEmpty &&
                              index == _pinIndex - 1
                          ? const Color(0xFF000E26)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _currentPin[index],
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          buildKeyPad(),
        ],
      ),
    );
  }

  Widget buildKeyPad() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildKeyPadRow(["1", "2", "3"]),
          const SizedBox(height: 15),
          buildKeyPadRow(["4", "5", "6"]),
          const SizedBox(height: 15),
          buildKeyPadRow(["7", "8", "9"]),
          const SizedBox(height: 15),
          buildKeyPadRow([null, "0", "back"]),
        ],
      ),
    );
  }

  Widget buildKeyPadRow(List<String?> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) {
          if (key == null) {
            return const SizedBox(width: 80); // Empty space for alignment
          } else if (key == "back") {
            return buildKey(key, Icons.backspace);
          } else {
            return buildKey(key);
          }
        }).toList(),
      ),
    );
  }

  Widget buildKey(String value, [IconData? icon]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _blinkKey = value; // Set the key to blink
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _blinkKey = null; // Reset after blinking
          });
        });
        _handleKeyTap(value);
      },
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _blinkKey == value ? Colors.grey.shade400 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: icon == null
            ? Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            : Icon(
                icon,
                size: 28,
                color: Colors.black,
              ),
      ),
    );
  }
}
