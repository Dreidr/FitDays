import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/models/user_profile.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;
  static const _profileKey = "user_profile";
  static const _onboardingKey = "onboarding_complete";

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint("SharedPrefs initialized");
  }

  // Onboarding
  static bool get isOnboardingComplete =>
      _prefs?.getBool(_onboardingKey) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_onboardingKey, value);
  }

  // Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _prefs?.setString(_profileKey, jsonString);
  }

  static UserProfile? getUserProfile() {
    final s = _prefs?.getString(_profileKey);
    if (s == null || s.isEmpty) return null;

    final map = jsonDecode(s) as Map<String, dynamic>;
    return UserProfile.fromJson(map);
  }

  static Future<void> clearUserProfile() async {
    await _prefs?.remove(_profileKey);
  }
}
