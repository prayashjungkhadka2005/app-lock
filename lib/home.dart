import 'package:bbl_security/AppsScreen.dart';
import 'package:bbl_security/LoginScreen.dart'; 
import 'package:bbl_security/controllers/apps_controller.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> getPermissions() async {
    if (!(await Get.find<MethodChannelController>().checkOverlayPermission()) ||
        !(await Get.find<MethodChannelController>()
            .checkUsageStatePermission())) {
      Get.find<MethodChannelController>().update();
      askPermissionBottomSheet(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isPinSetupComplete = prefs.getBool('isPinSetupComplete') ?? false;
      print('PIN setup complete status: $isPinSetupComplete');
      if (isPinSetupComplete) {
        await Get.find<AppsController>().getAppsData();
        await Get.find<AppsController>().getLockedApps();
        await getPermissions();
        Get.find<MethodChannelController>().addToLockedAppsMethod();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppsScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
