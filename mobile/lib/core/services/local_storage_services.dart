import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/models/user_profile.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;
  static const _profileKey = "user_profile";
  static const _onboardingKey = "onboarding_complete";

  static String get displayName {
    final p = getUserProfile();
    final n = p?.name?.trim();
    return (n != null && n.isNotEmpty) ? n : "User";
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // ✅ Auth stub (local only)
  static const _loggedInKey = "is_logged_in";

  static bool get isLoggedIn => _prefs?.getBool(_loggedInKey) ?? false;

  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_loggedInKey, value);
  }

  static bool get hasRegisteredUser =>
      getUserProfile()?.email.isNotEmpty == true;

  // Register = save profile + logged in
  static Future<void> register({
    required String email,
    required String password,
    required DateTime startDate, // ✅ add
    List<String> workoutDays = const [],
  }) async {
    final s = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    ); // date-only

    final profile = UserProfile(
      email: email.trim(),
      password: password,
      startDate: s,
      workoutDays: workoutDays,
    );

    await saveUserProfile(profile);
    await setLoggedIn(true);
  }

  // Login = compare with stored profile
  static bool login({required String email, required String password}) {
    final profile = getUserProfile();
    if (profile == null) return false;

    final ok = profile.email == email.trim() && profile.password == password;
    if (ok) {
      _prefs?.setBool(_loggedInKey, true);
    }
    return ok;
  }

  static Future<void> logout() async {
    await setLoggedIn(false);
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint("SharedPrefs initialized");
  }

  static String get displayEmail {
    final p = getUserProfile();
    final e = p?.email.trim();
    return (e != null && e.isNotEmpty) ? e : "—";
  }

  // Onboarding
  static bool get isOnboardingComplete =>
      _prefs?.getBool(_onboardingKey) ?? false;

  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_onboardingKey, value);
  }

  static const _skippedKey = "onboarding_skipped";

  // ✅ Profile completion (separate from onboarding_skipped)
  static const _profileCompleteKey = "profile_complete";

  static bool get isProfileComplete =>
      _prefs?.getBool(_profileCompleteKey) ?? false;

  static Future<void> setProfileComplete(bool value) async {
    await _prefs?.setBool(_profileCompleteKey, value);
  }

  static bool get isOnboardingSkipped => _prefs?.getBool(_skippedKey) ?? false;

  static Future<void> setOnboardingSkipped(bool value) async {
    await _prefs?.setBool(_skippedKey, value);
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
