import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _locationNotifications = true;
  bool _darkMode = true;

  bool get locationNotifications => _locationNotifications;
  bool get darkMode => _darkMode;

  void setLocationNotifications(bool value) {
    _locationNotifications = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }
}
