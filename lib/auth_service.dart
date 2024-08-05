import 'package:flutter/services.dart';

class AuthService {
  static const MethodChannel _channel = MethodChannel('flutter.native/auth');

  static Future<void> showAuthScreen() async {
    await _channel.invokeMethod('showAuthScreen');
  }
}
