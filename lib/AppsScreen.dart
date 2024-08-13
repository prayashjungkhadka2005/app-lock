import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/apps_controller.dart';
import '../controllers/method_channel_controller.dart';
import '../controllers/permission_controller.dart';
import '../widgets/permission_dialog.dart';

class AppsScreen extends StatefulWidget {
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
    // Start all async operations simultaneously
    final getAppDataFuture = Get.find<AppsController>().getAppsData();
    final getLockedAppsFuture = Get.find<AppsController>().getLockedApps();
    final getPermissionsFuture = getPermissions();

    // Await them all at once with explicit type
    await Future.wait<void>([
      getAppDataFuture,
      getLockedAppsFuture,
      getPermissionsFuture,
    ]);

    setState(() {
      isLoading = false;
    });
  });
}


  Widget buildIcon(Application app) {
    return FutureBuilder<Uint8List?>(
      future: Future.value(Get.find<AppsController>().getAppIcon(app.appName)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(Icons.android);
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return CircleAvatar(
            backgroundImage: MemoryImage(snapshot.data!),
            backgroundColor: Theme.of(context).primaryColorDark,
          );
        } else {
          return Icon(Icons.android);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 40,
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              'BBL Security',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 30,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Not Secured',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: GetBuilder<AppsController>(
                      id: Get.find<AppsController>().addRemoveToUnlockUpdate,
                      builder: (appsController) {
                        return ListView.builder(
                          itemCount: appsController.unLockList.length,
                          itemBuilder: (context, index) {
                            Application app = appsController.unLockList[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 4),
                                color: Colors.grey[200],
                                child: ListTile(
                                  leading: buildIcon(app),
                                  title: Text(app.appName),
                                  trailing: SizedBox(
                                    width: 60,
                                    child: FlutterSwitch(
                                      width: 50.0,
                                      height: 25.0,
                                      valueFontSize: 25.0,
                                      toggleColor: Colors.white,
                                      activeColor:
                                          Theme.of(context).primaryColor,
                                      inactiveColor:
                                          Theme.of(context).primaryColorDark,
                                      toggleSize: 20.0,
                                      value: appsController.selectLockList
                                          .contains(app.appName),
                                      borderRadius: 30.0,
                                      padding: 2.0,
                                      showOnOff: false,
                                      onToggle: (val) async {
                                        if (val) {
                                          await appsController.addToLockedApps(
                                              app, context);
                                        } else {
                                          await appsController
                                              .removeFromLockedApps(
                                                  app, context);
                                        }
                                        Get.find<MethodChannelController>()
                                            .addToLockedAppsMethod();
                                      },
                                    ),
                                  ),
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
