import 'dart:developer';
import 'dart:typed_data';
import 'package:bbl_security/controllers/method_channel_controller.dart';
import 'package:bbl_security/services/constants.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bbl_model.dart';

class AppsController extends GetxController implements GetxService {
  SharedPreferences prefs;
  AppsController({required this.prefs});

  int? selectQuestion;
  TextEditingController typeAnswer = TextEditingController();
  TextEditingController checkAnswer = TextEditingController();
  List<Application> unLockList = [];
  List<BBLDataModel> lockList = [];
  List<String> selectLockList = [];
  bool addToAppsLoading = false;

  List<String> excludedApps = ["com.android.settings"];

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

  setSplash() {
    prefs.setBool("Splash", true);
    return prefs.getBool("Splash");
  }

  Future<bool> getSplash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("Splash") ?? false;
  }

  excludeApps() {
    for (var e in excludedApps) {
      unLockList.removeWhere((element) => element.packageName == e);
    }
  }

  Future<void> getAppsData() async {
    try {
      unLockList = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: true,
        onlyAppsWithLaunchIntent: true,
      );
      excludeApps();
    } catch (e) {
      log("Error fetching apps: $e", name: "getAppsData");
    }
    update();
  }

  Future<void> addRemoveFromLockedApps(BBLData app) async {
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
      log("Error in addRemoveFromLockedApps: $e",
          name: "addRemoveFromLockedApps");
    }
    addToAppsLoading = false;
    update();
    displayLatestLockedApps();
  }

  Future<void> addToLockedApps(Application app, BuildContext context) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);

    try {
      if (!selectLockList.contains(app.appName)) {
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
          Get.find<MethodChannelController>().addToLockedAppsMethod();
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("Error in addToLockedApps: $e", name: "addToLockedApps");
    } finally {
      await prefs.setString(
          AppConstants.lockedApps, bblDataModelToJson(lockList));
      addToAppsLoading = false;
      update([addRemoveToUnlockUpdate]);
    }
  }

  Future<void> removeFromLockedApps(
      Application app, BuildContext context) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);

    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere((em) => em.application!.appName == app.appName);
      }
    } catch (e) {
      log("Error in removeFromLockedApps: $e", name: "removeFromLockedApps");
    } finally {
      await prefs.setString(
          AppConstants.lockedApps, bblDataModelToJson(lockList));
      addToAppsLoading = false;
      update([addRemoveToUnlockUpdate]);
      displayLatestLockedApps();
    }
  }

  Future<void> getLockedApps() async {
    try {
      lockList =
          bblDataModelFromJson(prefs.getString(AppConstants.lockedApps) ?? '');
      selectLockList.clear();
      for (var e in lockList) {
        selectLockList.add(e.application!.appName);
      }
    } catch (e) {
      log("Error in getLockedApps: $e", name: "getLockedApps");
    }

    update();
  }

  Uint8List getAppIcon(String appName) {
    int index = unLockList.indexWhere((element) {
      return appName == element.appName;
    });

    if (index != -1 && unLockList[index] is ApplicationWithIcon) {
      return (unLockList[index] as ApplicationWithIcon).icon;
    } else {
      return Uint8List(0);
    }
  }

  void displayLatestLockedApps() {
    log("Latest Locked Apps: ${lockList.map((e) => e.application!.appName).toList()}",
        name: "displayLatestLockedApps");

    Fluttertoast.showToast(
        msg: "Updated Locked Apps: ${lockList.length} apps",
        toastLength: Toast.LENGTH_SHORT);
  }
}