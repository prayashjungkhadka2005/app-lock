import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';

void askPermissionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    barrierColor: Colors.black.withOpacity(0.8),
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const AskPermissionBottomSheet();
    },
  );
}

class AskPermissionBottomSheet extends StatelessWidget {
  const AskPermissionBottomSheet({Key? key}) : super(key: key);

  Widget permissionWidget(BuildContext context, String name, bool permission,
      IconData icon, String description, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: GestureDetector(
        onTap: permission ? null : onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: permission ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: permission ? Colors.green : Theme.of(context).primaryColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon,
                color: permission ? Colors.green : Colors.red, size: 28),
            title: Text(
              name,
              style: TextStyle(
                color: permission
                    ? Colors.green[800]
                    : Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              description,
              style: TextStyle(
                color: permission ? Colors.green[600] : Colors.red[400],
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              permission ? Icons.check_circle : Icons.error_outline,
              color: permission ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkPermissions(MethodChannelController state) async {
    await state.checkOverlayPermission();
    await state.checkUsageStatePermission();
    await state.checkBatteryOptimizationPermission();
  }

  Future<void> confirmPermissions(
      BuildContext context, MethodChannelController state) async {
    await checkPermissions(state);

    if (!state.isOverlayPermissionGiven ||
        !state.isUsageStatPermissionGiven ||
        !state.isBatteryOptimizationIgnored) {
      Fluttertoast.showToast(
        msg: "Please grant all required permissions.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.cancel();
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "All permissions granted.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            // Dialog content
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: GetBuilder<MethodChannelController>(builder: (state) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Text(
                            "To ensure the best experience, please grant the following permissions:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        permissionWidget(
                          context,
                          "System Overlay",
                          state.isOverlayPermissionGiven,
                          Icons.visibility,
                          "Allows the app to display over other apps.",
                          () async {
                            if (!state.isOverlayPermissionGiven) {
                              await state.askOverlayPermission();
                            }
                          },
                        ),
                        permissionWidget(
                          context,
                          "Usage Access",
                          state.isUsageStatPermissionGiven,
                          Icons.bar_chart,
                          "Provides data on app usage statistics.",
                          () async {
                            if (!state.isUsageStatPermissionGiven) {
                              await state.askUsageStatsPermission();
                            }
                          },
                        ),
                        permissionWidget(
                          context,
                          "Ignore Battery Optimizations",
                          state.isBatteryOptimizationIgnored,
                          Icons.battery_alert,
                          "Prevents the app from being put to sleep.",
                          () async {
                            if (!state.isBatteryOptimizationIgnored) {
                              await state.askBatteryOptimizationPermission();
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                            ),
                            onPressed: () async {
                              Fluttertoast.cancel();
                              await confirmPermissions(context, state);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
