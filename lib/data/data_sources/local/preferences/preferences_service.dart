import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // Theme Mode
  Future<bool> setThemeMode(String mode) async {
    return await _prefs.setString(AppConstants.themeModeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeModeKey);
  }

  // Language
  Future<bool> setLanguage(String language) async {
    return await _prefs.setString(AppConstants.languageKey, language);
  }

  String? getLanguage() {
    return _prefs.getString(AppConstants.languageKey);
  }

  // Generic methods
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }
}

