import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

enum ConnectionStatus { connected, disconnected, connecting }

class SensorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService.instance;

  SensorData _sensorData = SensorData.initial();
  bool _isLoading = false;
  String? _error;
  bool _isDarkMode = true;
  Timer? _fetchTimer;
  DateTime _lastUpdated = DateTime.now();
  ConnectionStatus _connectionStatus = ConnectionStatus.connecting;
  int _failedAttempts = 0;

  // Getters
  SensorData get sensorData => _sensorData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDarkMode => _isDarkMode;
  DateTime get lastUpdated => _lastUpdated;
  bool get hasAlert => _sensorData.babyTemperature > Thresholds.babyTempMax;
  ConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;

  SensorProvider() {
    _loadThemePreference();
    startFetching();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      notifyListeners();
    } catch (e) {
      // Use default dark mode if preferences fail
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      // Continue even if save fails
    }
    notifyListeners();
  }

  void startFetching() {
    // Fetch immediately
    fetchSensorData();

    // Then fetch every 5 seconds
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(Thresholds.fetchInterval, (_) {
      fetchSensorData();
    });
  }

  void stopFetching() {
    _fetchTimer?.cancel();
  }

  Future<void> fetchSensorData() async {
    if (_isLoading) return; // Prevent concurrent fetches

    _isLoading = true;
    _error = null;

    if (_connectionStatus != ConnectionStatus.connected) {
      _connectionStatus = ConnectionStatus.connecting;
      notifyListeners();
    }

    try {
      final data = await _apiService.fetchSensorData();

      if (data != null) {
        _sensorData = data;
        _lastUpdated = DateTime.now();
        _connectionStatus = ConnectionStatus.connected;
        _failedAttempts = 0;
        _error = null;

        // Check for dangers and send notifications
        final dangers = _notificationService.analyzeDataForDanger(data);
        if (dangers.isNotEmpty) {
          await _notificationService.sendDangerNotification(dangers);
        }
      } else {
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          _connectionStatus = ConnectionStatus.disconnected;
          _error = 'Unable to connect to sensor. Retrying...';
        }
      }
    } catch (e) {
      _failedAttempts++;
      _error = 'Connection error: $e';
      if (_failedAttempts >= 3) {
        _connectionStatus = ConnectionStatus.disconnected;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Manual refresh
  Future<void> refresh() async {
    _failedAttempts = 0;
    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
    await fetchSensorData();
  }

  @override
  void dispose() {
    stopFetching();
    super.dispose();
  }
}
