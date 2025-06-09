import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static SharedPreferences? _prefs;

  StorageService._internal();

  factory StorageService() => _instance;

  // Inicializar SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Métodos para tipos básicos
  Future<bool> setBool(String key, bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs?.getStringList(key) ?? defaultValue ?? [];
  }

  // Métodos para objetos JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error encoding JSON for key $key: $e');
      return false;
    }
  }

  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JSON for key $key: $e');
      return null;
    }
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      print('Error encoding JSON list for key $key: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error decoding JSON list for key $key: $e');
      return [];
    }
  }

  // Métodos utilitarios
  Future<bool> remove(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.clear();
  }

  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  Set<String> getKeys() {
    return _prefs?.getKeys() ?? <String>{};
  }

  // Métodos específicos para la app
  static const String _firstLaunchKey = 'first_launch';
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _reminderSoundKey = 'reminder_sound';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _autoCleanupKey = 'auto_cleanup';
  static const String _defaultReminderTimeKey = 'default_reminder_time';
  static const String _userPreferencesKey = 'user_preferences';

  bool get isFirstLaunch => getBool(_firstLaunchKey, defaultValue: true);
  Future<void> setFirstLaunchCompleted() => setBool(_firstLaunchKey, false);

  bool get notificationsEnabled =>
      getBool(_notificationEnabledKey, defaultValue: true);
  Future<void> setNotificationsEnabled(bool enabled) =>
      setBool(_notificationEnabledKey, enabled);

  String get reminderSound =>
      getString(_reminderSoundKey, defaultValue: 'default');
  Future<void> setReminderSound(String sound) =>
      setString(_reminderSoundKey, sound);

  bool get vibrationEnabled =>
      getBool(_vibrationEnabledKey, defaultValue: true);
  Future<void> setVibrationEnabled(bool enabled) =>
      setBool(_vibrationEnabledKey, enabled);

  bool get autoCleanupEnabled => getBool(_autoCleanupKey, defaultValue: false);
  Future<void> setAutoCleanupEnabled(bool enabled) =>
      setBool(_autoCleanupKey, enabled);

  int get defaultReminderTime =>
      getInt(_defaultReminderTimeKey, defaultValue: 9); // 9 AM
  Future<void> setDefaultReminderTime(int hour) =>
      setInt(_defaultReminderTimeKey, hour);

  Map<String, dynamic> get userPreferences =>
      getJson(_userPreferencesKey) ?? {};
  Future<void> setUserPreferences(Map<String, dynamic> preferences) =>
      setJson(_userPreferencesKey, preferences);

  // Método para backup/restore de preferencias
  Future<String> exportPreferences() async {
    final allKeys = getKeys();
    final preferences = <String, dynamic>{};

    for (final key in allKeys) {
      if (_prefs!.get(key) != null) {
        preferences[key] = _prefs!.get(key);
      }
    }

    return jsonEncode(preferences);
  }

  Future<bool> importPreferences(String preferencesJson) async {
    try {
      final Map<String, dynamic> preferences = jsonDecode(preferencesJson);

      for (final entry in preferences.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is bool) {
          await setBool(key, value);
        } else if (value is String) {
          await setString(key, value);
        } else if (value is int) {
          await setInt(key, value);
        } else if (value is double) {
          await setDouble(key, value);
        } else if (value is List<String>) {
          await setStringList(key, value);
        }
      }

      return true;
    } catch (e) {
      print('Error importing preferences: $e');
      return false;
    }
  }

  // Estadísticas de uso
  void incrementUsageCounter(String feature) {
    final currentCount = getInt('usage_$feature', defaultValue: 0);
    setInt('usage_$feature', currentCount + 1);
  }

  int getUsageCounter(String feature) {
    return getInt('usage_$feature', defaultValue: 0);
  }

  Map<String, int> getAllUsageCounters() {
    final keys = getKeys().where((key) => key.startsWith('usage_'));
    final counters = <String, int>{};

    for (final key in keys) {
      final feature = key.substring(6); // Remove 'usage_' prefix
      counters[feature] = getInt(key);
    }

    return counters;
  }
}
