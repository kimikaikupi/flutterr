class ApiConstants {
  static const String baseUrl = 'https://capstone.iceiy.com';
  static const String fetchSensorsEndpoint = '/fetch_sensors.php';

  static String get fetchSensorsUrl => '$baseUrl$fetchSensorsEndpoint';
}

class Thresholds {
  static const double roomTempMax = 28.0;
  static const double roomTempMin = 16.0;
  static const double humidityMin = 30.0;
  static const double humidityMax = 70.0;
  static const double babyTempMax = 38.0;
  static const double babyTempMin = 35.5;
  static const double babyOxygenMin = 95.0;
  static const double heartRateMin = 60.0;
  static const double heartRateMax = 160.0;

  static const Duration notificationCooldown = Duration(seconds: 60);
  static const Duration fetchInterval = Duration(seconds: 5);
}
