import 'package:bbl_security/controllers/apps_controller.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/controllers/permission_controller.dart';
import 'package:bbl_security/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AppsScreen extends StatefulWidget {
  const AppsScreen({Key? key}) : super(key: key);

  @override
  _AppsScreenState createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  bool isLoading = true;

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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Image(
              image: AssetImage('assets/logo.png'),
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            Text(
              'BBL Security',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        size: 30,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Not Secured',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GetBuilder<AppsController>(
                      builder: (appsController) {
                        return ListView.builder(
                          itemCount: appsController.unLockList.length,
                          itemBuilder: (context, index) {
                            final app = appsController.unLockList[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.grey[200],
                              child: ListTile(
                                leading: app is ApplicationWithIcon
                                    ? Image.memory(app.icon)
                                    : const Icon(Icons.android),
                                title: Text(app.appName),
                                trailing: const Icon(
                                  Icons.lock_open,
                                  color: Colors.redAccent,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
