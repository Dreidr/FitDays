import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/models/saved_workout.dart';

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

  static const String _savedWorkoutsKey = "saved_workouts_v1";
  static const String _completedDaysKey =
      "completed_days_v1"; // store ISO date strings

  // SAVED (GENERATED) WORKOUTS
  // -------------------------

  static List<SavedWorkout> getSavedWorkouts() {
    final list = _prefs?.getStringList(_savedWorkoutsKey) ?? <String>[];
    final workouts = list.map(SavedWorkout.fromRawJson).toList();
    workouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return workouts;
  }

  static SavedWorkout? getSavedWorkoutById(String id) {
    final list = _prefs?.getStringList(_savedWorkoutsKey) ?? <String>[];
    for (final raw in list) {
      final w = SavedWorkout.fromRawJson(raw);
      if (w.id == id) return w;
    }
    return null;
  }

  static Future<void> saveGeneratedWorkout(SavedWorkout workout) async {
    final list = _prefs?.getStringList(_savedWorkoutsKey) ?? <String>[];

    // upsert by id
    final idx = list.indexWhere((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map["id"] == workout.id;
    });

    if (idx >= 0) {
      list[idx] = workout.toRawJson();
    } else {
      list.add(workout.toRawJson());
    }

    await _prefs?.setStringList(_savedWorkoutsKey, list);
  }

  static Future<void> deleteSavedWorkout(String id) async {
    final list = _prefs?.getStringList(_savedWorkoutsKey) ?? <String>[];
    list.removeWhere((raw) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map["id"] == id;
    });
    await _prefs?.setStringList(_savedWorkoutsKey, list);
  }

  // -------------------------
  // COMPLETED WORKOUT DAYS (MVP)
  // -------------------------

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _dayKey(DateTime d) => _dateOnly(d).toIso8601String();

  static Future<void> markWorkoutCompletedForDay(DateTime day) async {
    final list = _prefs?.getStringList(_completedDaysKey) ?? <String>[];
    final key = _dayKey(day);

    if (!list.contains(key)) {
      list.add(key);
      await _prefs?.setStringList(_completedDaysKey, list);
    }
  }

  static Future<void> unmarkWorkoutCompletedForDay(DateTime day) async {
    final list = _prefs?.getStringList(_completedDaysKey) ?? <String>[];
    final key = _dayKey(day);

    list.remove(key);
    await _prefs?.setStringList(_completedDaysKey, list);
  }

  static bool isWorkoutCompletedOnDay(DateTime day) {
    final list = _prefs?.getStringList(_completedDaysKey) ?? <String>[];
    return list.contains(_dayKey(day));
  }

  static Set<DateTime> getCompletedDays() {
    final list = _prefs?.getStringList(_completedDaysKey) ?? <String>[];
    return list.map((s) => DateTime.parse(s)).toSet();
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
