import 'dart:developer';
import 'dart:typed_data';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/services/constants.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Allows showing toast messages for user feedback
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bbl_model.dart';

class AppsController extends GetxController implements GetxService {
  SharedPreferences prefs;
  AppsController({required this.prefs});

  // String? dummyPasscode;
  int? selectQuestion;
  TextEditingController typeAnswer = TextEditingController();
  TextEditingController checkAnswer = TextEditingController();
  List<Application> unLockList =
      []; // list of installed applications that are not locked
  List<BBLDataModel> lockList = []; // list of locked applications
  List<String> selectLockList =
      []; //list of app names currently selected for locking
  bool addToAppsLoading =
      false; // Indicates if an app is being added to or removed from the lock list

  List<String> excludedApps = [
    "com.android.settings"
  ]; //Apps that are excluded from being unlocked

  int appSearchUpdate = 1;
  int addRemoveToUnlockUpdate = 2;
  int addRemoveToUnlockUpdateSearch = 3;

  changeQuestionIndex(index) {
    selectQuestion = index;
    update();
  }

  resetAskQuetionsPage() {
    selectQuestion = null;
    typeAnswer.clear();
    checkAnswer.clear();
  }

  savePasscode(counter) {
    prefs.setString(AppConstants.setPassCode, counter);
    Get.find<MethodChannelController>().setPassword();
    log("${prefs.getString(AppConstants.setPassCode)}", name: "save passcode");
  }

  getPasscode() {
    return prefs.getString(AppConstants.setPassCode) ?? "";
  }

  removePasscode() {
    return prefs.remove(AppConstants.setPassCode);
  }

  setSplash() {
    prefs.setBool("Splash", true);
    return prefs.getBool("Splash");
  }

  getSplash() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool("Splash")) != null) {
      return true;
    } else {
      return false;
    }
  }

  excludeApps() {
    for (var e in excludedApps) {
      unLockList.removeWhere((element) => element.packageName == e);
    }
  }

  getAppsData() async {
    unLockList = await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    excludeApps();
    update();
  }

  addRemoveFromLockedApps(BBLData app) {
    addToAppsLoading = true;
    update();
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere(
            (element) => element.application!.appName == app.appName);
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            BBLDataModel(
              isLocked: true,
              application: BBLData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: app.category,
                dataDir: app.dataDir,
                enabled: app.enabled,
                icon: getAppIcon(app.appName),
                packageName: app.packageName,
                systemApp: app.systemApp,
                versionCode: app.versionCode,
                versionName: app.versionName,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addRemoveFromLockedAppsFromSearch");
    }
    addToAppsLoading = false;
    update();
  }

  addToLockedApps(Application app, context) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere((em) => em.application!.appName == app.appName);
        log("REMOVE: $selectLockList");
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            BBLDataModel(
              isLocked: true,
              application: BBLData(
                apkFilePath: app.apkFilePath,
                appName: app.appName,
                category: "${app.category}",
                dataDir: "${app.dataDir}",
                enabled: app.enabled,
                icon: (app as ApplicationWithIcon).icon,
                packageName: app.packageName,
                systemApp: app.systemApp,
                versionCode: '${app.versionCode}',
                versionName: '${app.versionName}',
              ),
            ),
          );
          log("ADD: $selectLockList", name: "addToLockedApps");
          Get.find<MethodChannelController>().addToLockedAppsMethod();
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addToLockedApps");
    }
    prefs.setString(AppConstants.lockedApps, bblDataModelToJson(lockList));
    addToAppsLoading = false;
    update([addRemoveToUnlockUpdate]);
  }

  getLockedApps() {
    try {
      lockList =
          bblDataModelFromJson(prefs.getString(AppConstants.lockedApps) ?? '');
      selectLockList.clear();
      log('${lockList.length}', name: "STORED LIST");
      for (var e in lockList) {
        selectLockList.add(e.application!.appName);
      }
      log('${lockList.length}-$selectLockList', name: "Locked Apps");
    } catch (e) {
      log("-------$e", name: "getLockedApps");
    }

    update();
  }

  Uint8List getAppIcon(String appName) {
    return (unLockList[unLockList.indexWhere((element) {
      return appName == element.appName;
    })] as ApplicationWithIcon)
        .icon;
  }

  void removeFromLockedApps(Application app, BuildContext context) {}
}
