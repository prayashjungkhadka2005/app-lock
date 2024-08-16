import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bbl_security/controllers/apps_controller.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/widgets/permission_dialog.dart';

class AppsScreen extends StatefulWidget {
  @override
  _AppsScreenState createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  bool isLoading = true;
  String searchQuery = "";

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
      final getAppDataFuture = Get.find<AppsController>().getAppsData();
      final getLockedAppsFuture = Get.find<AppsController>().getLockedApps();
      final getPermissionsFuture = getPermissions();

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
            backgroundColor: Colors.transparent,
            radius: 25,
            child: ClipOval(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        } else {
          return Icon(Icons.android);
        }
      },
    );
  }

  Future<void> toggleAppLock(Application app) async {
    final appsController = Get.find<AppsController>();

    if (appsController.selectLockList.contains(app.appName)) {
      // Show confirmation dialog before removing the app from the locked list
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remove App",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Are you sure you want to move ',
                          ),
                          TextSpan(
                            text: '"${app.appName}"',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' from the secured list to the unsecured list?\n\n',
                          ),
                          TextSpan(
                            text:
                                'This action will make "${app.appName}" accessible without additional security. Please confirm if you wish to proceed.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // Optimistically update UI
                            setState(() {
                              appsController.selectLockList.remove(app.appName);
                            });

                            // Remove app from locked list in background
                            await appsController.removeFromLockedApps(
                                app, context);
                            await Get.find<MethodChannelController>()
                                .addToLockedAppsMethod();

                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Remove",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Add app to locked list
      await appsController.addToLockedApps(app, context);
      await Get.find<MethodChannelController>().addToLockedAppsMethod();

      // Optimistically update UI
      setState(() {
        appsController.selectLockList.add(app.appName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF000E26),
        automaticallyImplyLeading: false,
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                        Icons.lock_outline,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Secure Applications',
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
                        List<Application> lockedApps =
                            appsController.unLockList.where((app) {
                          return appsController.selectLockList
                              .contains(app.appName);
                        }).toList();

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                0.75, // Adjusted for better appearance
                          ),
                          itemCount: lockedApps.length,
                          itemBuilder: (context, index) {
                            Application app = lockedApps[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildIcon(app),
                                SizedBox(height: 5),
                                Text(
                                  app.appName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Divider(height: 32),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Search Not Secured Applications",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: GetBuilder<AppsController>(
                      id: Get.find<AppsController>().addRemoveToUnlockUpdate,
                      builder: (appsController) {
                        List<Application> filteredApps =
                            appsController.unLockList.where((app) {
                          return app.appName
                              .toLowerCase()
                              .contains(searchQuery);
                        }).toList();

                        filteredApps.sort((a, b) => a.appName
                            .toLowerCase()
                            .compareTo(b.appName.toLowerCase()));

                        return ListView.builder(
                          itemCount: filteredApps.length,
                          itemBuilder: (context, index) {
                            Application app = filteredApps[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.grey[100],
                                child: ListTile(
                                  leading: buildIcon(app),
                                  title: Text(
                                    app.appName,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  trailing: SizedBox(
                                    width: 60,
                                    child: FlutterSwitch(
                                      width: 50.0,
                                      height: 25.0,
                                      valueFontSize: 12.0,
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
                                        await toggleAppLock(app);
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
