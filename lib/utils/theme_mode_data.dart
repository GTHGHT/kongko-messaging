import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeModeData extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  ThemeMode _themeMode = ThemeMode.system;

  void loadTheme() {
    _storage.read(key: "THEME_MODE").then(
          (value) => _themeMode =
              value != null ? modeFromString(value) : ThemeMode.system,
        );
  }

  ThemeMode modeFromString(String modeString) {
    if (modeString == "ThemeMode.dark") {
      return ThemeMode.dark;
    } else if (modeString == "ThemeMode.light") {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }

  void changeTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    _storage.write(key: "THEME_MODE", value: themeMode.toString());
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;
}