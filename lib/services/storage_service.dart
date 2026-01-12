import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _routesKey = 'routes';
  static const String _bookingsKey = 'bookings';
  static const String _vehiclesKey = 'vehicles';
  static const String _currentUserKey = 'currentUser';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  static Future<List<Map<String, dynamic>>> getList(String key) async {
    try {
      final prefs = await _prefs;
      final data = prefs.getString(key);
      if (data == null) return [];
      final decoded = jsonDecode(data) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error loading $key: $e');
      return [];
    }
  }

  static Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving $key: $e');
    }
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final prefs = await _prefs;
      final data = prefs.getString(key);
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading $key: $e');
      return null;
    }
  }

  static Future<void> saveObject(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving $key: $e');
    }
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }

  static Future<void> removeKey(String key) async {
    try {
      final prefs = await _prefs;
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Error removing $key: $e');
    }
  }

  static String get usersKey => _usersKey;
  static String get routesKey => _routesKey;
  static String get bookingsKey => _bookingsKey;
  static String get vehiclesKey => _vehiclesKey;
  static String get currentUserKey => _currentUserKey;
}
 