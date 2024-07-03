import 'package:example/models/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool NotificationsEnabled = true;
  bool get notificationsEnabled => NotificationsEnabled;

  var isDarkTheme=false,block,isblock;
  SettingsProvider() {
    _loadSettings();
  }

  void change_theme(var value){
    isDarkTheme=value;
    notifyListeners();
  }
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    NotificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    isDarkTheme = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) async {
    NotificationsEnabled = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }
  void set_isblock(bool value) async {
    isblock = value;  // Corrected this line to update isblock instead of _notificationsEnabled
    notifyListeners();
  }
  void set_blocks(var value) async {
    block = value;  // Corrected this line to update isblock instead of _notificationsEnabled
    notifyListeners();
  }
  void setMode(bool value) async {
    isDarkTheme = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
    notifyListeners();
  }
}