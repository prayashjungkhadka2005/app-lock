import 'package:bbl_security/AppsScreen.dart';
import 'package:bbl_security/controllers/apps_controller.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/controllers/permission_controller.dart';
import 'package:bbl_security/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

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
      await Get.find<AppsController>().getAppsData();
      await Get.find<AppsController>().getLockedApps();
      await Get.find<PermissionController>()
          .getPermission(Permission.ignoreBatteryOptimizations);
      await getPermissions();
      Get.find<MethodChannelController>().addToLockedAppsMethod();

      // Navigate to AppsScreen without 'const'
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AppsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
