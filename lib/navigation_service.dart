// lib/services/navigation_service.dart

import 'package:bbl_security/auth_screen.dart';
import 'package:bbl_security/main.dart';
import 'package:flutter/material.dart';

void showAuthScreen(String packageName) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => AuthScreen(packageName: packageName),
      fullscreenDialog: true,
    ),
  );
}
