import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenController extends GetxController implements GetxService {
  SharedPreferences prefs;
  HomeScreenController({required this.prefs});

  int isSelectPage = 0;
  PageController controller = PageController(initialPage: 0);

  onChangeMethod(int page) {
    isSelectPage = page;
    update();
   
  }
}
