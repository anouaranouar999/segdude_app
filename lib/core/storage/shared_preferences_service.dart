import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling local storage using SharedPreferences
/// This service provides an abstraction layer for storing and retrieving
/// user preferences and local data.

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  factory SharedPreferencesService() => _instance;
  SharedPreferencesService._internal();

  final _prefs = SharedPreferencesAsync();
  //----------------------------------------------------------------- Timing settings
  /// save selected days
  Future<String> saveDays(String key, String value) async {
    await _prefs.setString(key, value);
    return value;
  }

  /// Retrieve selected days
  Future<String?> getDays(String key) async {
    return await _prefs.getString(key);
  }

  //----------------------------------------------------------------- Generic Data
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return await _prefs.getString(key);
  }

  /// testing add subject

  Future<String> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
    return key;
  }

  Future<int?> getInt(String key) async {
    return await _prefs.getInt(key);
  }

  /// Remove a value by key
  Future<bool> remove(String key) async {
    await _prefs.remove(key);
    return true;
  }

  /// save string list
  Future<String> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
    return key;
  }

  /// Retrieve string list
  Future<List<String>?> getStringList(String key) async {
    return await _prefs.getStringList(key);
  }

  /// Clear all stored values
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return await _prefs.getBool(key);
  }

  /// Clear all stored values
  Future<bool> clear() async {
    await _prefs.clear();
    return true;
  }
}
