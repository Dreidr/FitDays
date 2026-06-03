import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/models/user_profile.dart';
import 'package:mobile/features/workout/models/saved_workout.dart';
import 'package:mobile/features/workout_play/models/active_workout_session.dart';

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

  static const _notificationsEnabledKey = "notifications_enabled";

  static bool get notificationsEnabled =>
      _prefs?.getBool(_notificationsEnabledKey) ?? false;

  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_notificationsEnabledKey, value);
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

  static const String _activeWorkoutSessionKey = 'active_workout_session';

  static Future<void> saveActiveWorkoutSession(
    ActiveWorkoutSession session,
  ) async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setString(
      _activeWorkoutSessionKey,
      jsonEncode(session.toJson()),
    );
  }

  static ActiveWorkoutSession? getActiveWorkoutSession() {
    final prefs = _prefs;
    if (prefs == null) return null;

    final raw = prefs.getString(_activeWorkoutSessionKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return ActiveWorkoutSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearActiveWorkoutSession() async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.remove(_activeWorkoutSessionKey);
  }
}
