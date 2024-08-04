import 'package:html/parser.dart';

class AppConstants {

  static const String setPassCode = "setPasscode";
  static const String saveQa = "saveQa";

  static const String appName = 'BBL Security';
  static const int appVersion = 1;

  // Shared Key
  static const String token = 'user_app_token';
  static const String userId = 'user_app_id';
  static const String lockedApps = 'lockedApps';

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }
}
