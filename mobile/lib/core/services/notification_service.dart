import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile/core/services/local_storage_services.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidAllowed = await android?.requestNotificationsPermission();
    final iosAllowed = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    return (androidAllowed ?? true) && (iosAllowed ?? true);
  }

  static Future<void> scheduleDailyWorkoutReminder() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_workout_reminders',
        'Daily Workout Reminders',
        channelDescription: 'Daily reminders to complete your workout.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.periodicallyShow(
      _dailyReminderId,
      'FitDays reminder',
      'Time for your workout. Let\'s keep your streak alive 💪',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    await LocalStorageService.setNotificationsEnabled(true);
  }

  static Future<void> cancelDailyWorkoutReminder() async {
    await _plugin.cancel(_dailyReminderId);
    await LocalStorageService.setNotificationsEnabled(false);
  }

  static void showSavedToast(bool enabled) {
    Fluttertoast.showToast(
      msg: enabled ? 'Workout reminders enabled' : 'Workout reminders disabled',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void logError(Object error) {
    debugPrint('Notification error: $error');
  }
}
