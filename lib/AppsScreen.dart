import 'package:bbl_security/controllers/apps_controller.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/controllers/permission_controller.dart';
import 'package:bbl_security/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(BBLSecurityApp());
}

class BBLSecurityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBL Security',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF000E26,
          {
            50: Color(0xFFE1E6F0),
            100: Color(0xFFB3BCCF),
            200: Color(0xFF8093AA),
            300: Color(0xFF4D6B8D),
            400: Color(0xFF1A3A6A),
            500: Color(0xFF000E26),
            600: Color(0xFF000B22),
            700: Color(0xFF00081E),
            800: Color(0xFF00051A),
            900: Color(0xFF00010D),
          },
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF000E26),
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
      ),
      home: AppsScreen(),
    );
  }
}

class AppsScreen extends StatefulWidget {
  @override
  _AppsScreenState createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  bool isLoading = true;

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
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getPermissions() async {
    if (!(await Get.find<MethodChannelController>().checkOverlayPermission()) ||
        !(await Get.find<MethodChannelController>()
            .checkUsageStatePermission())) {
      Get.find<MethodChannelController>().update();
      askPermissionBottomSheet(context);
    }
  }

  void _addNewApp(Application app) {
    setState(() {
      Get.find<AppsController>().addToLockedApps(app, context);
    });
  }

  void _showConfirmationDialog(
    BuildContext context,
    Application app,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 48,
                color: Colors.amber,
              ),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to move "${app.appName}" from the secured list to the unsecured list?\n\n'
                'This action will make "${app.appName}" accessible without additional security. Please confirm if you wish to proceed.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF000E26),
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeAppFromSecured(Application app) {
    _showConfirmationDialog(
      context,
      app,
      () {
        setState(() {
          Get.find<AppsController>().addRemoveToUnlockUpdate;
        });
      },
    );
  }

  void _showAddAppDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddAppDialog(
          notSecuredApps: Get.find<AppsController>().unLockList,
          onAdd: _addNewApp,
        );
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
                        Icons.lock_outline,
                        size: 30,
                        color: Color(0xFF000E26),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Secure Applications',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: List.generate(
                          Get.find<AppsController>().lockList.length + 1,
                          (index) {
                        if (index ==
                            Get.find<AppsController>().lockList.length) {
                          return GestureDetector(
                            onTap: _showAddAppDialog,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 36,
                                  color: Color(0xFF000E26),
                                ),
                              ),
                            ),
                          );
                        } else {
                          Application app =
                              Get.find<AppsController>().unLockList[index];
                          return GestureDetector(
                            onTap: () => _removeAppFromSecured(app),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: app is ApplicationWithIcon
                                        ? Image.memory(app.icon)
                                        : Icon(Icons.android, size: 40),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      app.appName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                  SizedBox(height: 12),
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
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: GetBuilder<AppsController>(
                      builder: (appsController) {
                        return ListView.builder(
                          itemCount: appsController.unLockList.length,
                          itemBuilder: (context, index) {
                            Application app = appsController.unLockList[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              color: Colors.grey[200],
                              child: ListTile(
                                leading: app is ApplicationWithIcon
                                    ? Image.memory(app.icon)
                                    : Icon(Icons.android),
                                title: Text(app.appName),
                                trailing: IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => _addNewApp(app),
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

class AddAppDialog extends StatelessWidget {
  final List<Application> notSecuredApps;
  final ValueChanged<Application> onAdd;

  AddAppDialog({
    required this.notSecuredApps,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add App',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: notSecuredApps.length,
          itemBuilder: (context, index) {
            Application app = notSecuredApps[index];
            return ListTile(
              leading: app is ApplicationWithIcon
                  ? Image.memory(app.icon)
                  : Icon(Icons.android),
              title: Text(app.appName),
              trailing: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  onAdd(app);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
