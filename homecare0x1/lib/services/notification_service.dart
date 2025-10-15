import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications and request permissions
  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Request permissions
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // Request notification permission (Android 13+)
        await Permission.notification.request();
        // Request exact alarm permission (Android 12+)
        if (await _isAndroid12OrHigher()) {
          await Permission.scheduleExactAlarm.request();
        }
      }
    } else {
      // Web: No explicit permission needed for local notifications, but limited support
      print('Web platform: Local notifications may have limited functionality');
    }

    // Android initialization
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization with permission requests
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize the plugin
    await _localNotifications.initialize(initSettings);
  }

  // Check if Android version is 12 or higher
  static Future<bool> _isAndroid12OrHigher() async {
    // For simplicity, assume Android 12+; use device_info_plus for precise version check
    return true;
  }

  // Schedule local notification for caregiver reminder
  static Future<void> scheduleShiftReminder({
    required String shiftId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Android notification details (alarm-like)
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'shift_reminder_channel',
      'Shift Reminders',
      channelDescription: 'Notifications for upcoming shifts',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Full-screen for alarm-like behavior
      sound: RawResourceAndroidNotificationSound('default'), // Use default sound
      category: AndroidNotificationCategory.alarm,
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Unique notification ID
    int id = Random().nextInt(100000);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Precise timing
    );
  }
}