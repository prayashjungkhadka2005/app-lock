import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/state_manager.dart';
import 'package:bbl_security/controllers/method_channel_controller.dart';

import '../services/constants.dart';

askPermissionBottomSheet(context) {
  return showModalBottomSheet(
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

  Widget permissionWidget(context, name, bool permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 6,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$name",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: !permission
                    ? Colors.grey[700]
                    : Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
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
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: GetBuilder<MethodChannelController>(builder: (state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        "AppLock needs system permissions to work with.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!state.isOverlayPermissionGiven)
                            GestureDetector(
                              onTap: () {
                                state.askOverlayPermission();
                              },
                              child: permissionWidget(
                                context,
                                "System overlay",
                                state.isOverlayPermissionGiven,
                              ),
                            ),
                          if (!state.isUsageStatPermissionGiven)
                            GestureDetector(
                              onTap: () {
                                state.askUsageStatsPermission();
                              },
                              child: permissionWidget(
                                context,
                                "Usage access",
                                state.isUsageStatPermissionGiven,
                              ),
                            )
                        ],
                      ),
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        if (await state.checkOverlayPermission() &&
                            await state.checkUsageStatePermission()) {
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Required permissions not given!");
                        }
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
