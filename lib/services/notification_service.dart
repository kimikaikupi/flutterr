import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/constants.dart';
import '../models/sensor_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  DateTime? _lastNotificationTime;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}',
        name: 'NotificationService');
  }

  List<String> analyzeDataForDanger(SensorData sensor) {
    List<String> dangers = [];

    // Room Temperature
    if (sensor.temperature > Thresholds.roomTempMax) {
      dangers.add('🌡️ Room too HOT (${sensor.temperature}°C)');
    } else if (sensor.temperature < Thresholds.roomTempMin) {
      dangers.add('🥶 Room too COLD (${sensor.temperature}°C)');
    }

    // Humidity
    if (sensor.humidity < Thresholds.humidityMin) {
      dangers.add('💧 Humidity too LOW (${sensor.humidity}%)');
    } else if (sensor.humidity > Thresholds.humidityMax) {
      dangers.add('💧 Humidity too HIGH (${sensor.humidity}%)');
    }

    // Baby Temperature
    if (sensor.babyTemperature > Thresholds.babyTempMax) {
      dangers.add('🤒 Baby has FEVER (${sensor.babyTemperature}°C)');
    } else if (sensor.babyTemperature < Thresholds.babyTempMin) {
      dangers.add('🥶 Baby temp too LOW (${sensor.babyTemperature}°C)');
    }

    // Oxygen
    if (sensor.babyOxygenLevel < Thresholds.babyOxygenMin) {
      dangers.add('🫁 Oxygen CRITICAL (${sensor.babyOxygenLevel}%)');
    }

    // Heart Rate
    if (sensor.heartRate < Thresholds.heartRateMin ||
        sensor.heartRate > Thresholds.heartRateMax) {
      dangers.add('💓 Abnormal Heart Rate (${sensor.heartRate} bpm)');
    }

    // Sound Level
    if (sensor.soundLevel == 'High' || sensor.soundLevel == 'Crying') {
      dangers.add('🔊 Baby is Crying/Loud');
    }

    return dangers;
  }

  Future<void> sendDangerNotification(List<String> issues) async {
    if (issues.isEmpty) return;

    final now = DateTime.now();

    // Check cooldown
    if (_lastNotificationTime != null) {
      final difference = now.difference(_lastNotificationTime!);
      if (difference < Thresholds.notificationCooldown) {
        return;
      }
    }

    final vibrationPattern = Int64List.fromList([0, 200, 100, 200, 100, 200]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'baby_monitor_alerts',
      'Baby Monitor Alerts',
      channelDescription: 'Critical alerts for baby monitoring',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      styleInformation: const BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '⚠️ BABY MONITOR ALERT!',
      issues.join('\n'),
      notificationDetails,
      payload: 'alert',
    );

    _lastNotificationTime = now;
  }
}
