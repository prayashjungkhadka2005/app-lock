import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

List<BBLDataModel> bblDataModelFromJson(String str) => List<BBLDataModel>.from(
    json.decode(str).map((x) => BBLDataModel.fromJson(x)));

String bblDataModelToJson(List<BBLDataModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BBLDataModel {
  BBLDataModel({
    this.isLocked,
    this.application,
  });

  bool? isLocked;
  BBLData? application;

  factory BBLDataModel.fromJson(Map<String, dynamic> json) => BBLDataModel(
        isLocked: json["isLocked"],
        application: json["application"] == null
            ? null
            : BBLData.fromJson(json["application"]),
      );

  Map<String, dynamic> toJson() => {
        "isLocked": isLocked,
        "application": application == null ? null : application!.toJson(),
      };
}

class BBLData {
  BBLData({
    required this.appName,
    this.icon,
    required this.apkFilePath,
    required this.versionName,
    required this.packageName,
    required this.versionCode,
    required this.dataDir,
    required this.systemApp,
    required this.category,
    required this.enabled,
  });

  String appName;
  Uint8List? icon;
  String apkFilePath;
  String packageName;
  String versionName;
  String versionCode;
  String dataDir;
  bool systemApp;
  String category;
  bool enabled;

  factory BBLData.fromJson(Map<String, dynamic> json) {
    Uint8List getUinit8List(data) {
      log("$data", name: 'getUinit8List');
      List<int> list = utf8.encode(data.toString());
      log("$data", name: 'getUinit8List2');
      return Uint8List.fromList(list);
    }

    return BBLData(
      appName: json["appName"] == null ? null : json["appName"],
      icon: getUinit8List(json["icon"]),
      apkFilePath: json["apkFilePath"] == null ? null : json["apkFilePath"],
      packageName: json["packageName"] == null ? null : json["packageName"],
      versionName: json["versionName"] == null ? null : json["versionName"],
      versionCode: json["versionCode"] == null ? null : json["versionCode"],
      dataDir: json["dataDir"] == null ? null : json["dataDir"],
      systemApp: json["systemApp"] == null ? null : json["systemApp"],
      category: json["category"] == null ? null : json["category"],
      enabled: json["enabled"] == null ? null : json["enabled"],
    );
  }

  Map<String, dynamic> toJson() {
    String getUinit8List(data) {
      return base64Encode(Uint8List.fromList(utf8.encode(data.toString())));
    }

    return {
      "appName": appName == null ? null : appName,
      "icon": icon == null ? null : getUinit8List(icon),
      "apkFilePath": apkFilePath == null ? null : apkFilePath,
      "packageName": packageName == null ? null : packageName,
      "versionName": versionName == null ? null : versionName,
      "versionCode": versionCode == null ? null : versionCode,
      "dataDir": dataDir == null ? null : dataDir,
      "systemApp": systemApp == null ? null : systemApp,
      "category": category == null ? null : category,
      "enabled": enabled == null ? null : enabled,
    };
  }
}
