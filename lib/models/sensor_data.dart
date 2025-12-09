class SensorData {
  final double temperature;
  final double humidity;
  final double babyTemperature;
  final double babyOxygenLevel;
  final int heartRate;
  final String? soundLevel;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.babyTemperature,
    required this.babyOxygenLevel,
    required this.heartRate,
    this.soundLevel,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: _parseDouble(
          json['temperature'] ?? json['room_temperature'] ?? json['temp']),
      humidity: _parseDouble(json['humidity'] ?? json['room_humidity']),
      babyTemperature: _parseDouble(json['baby_temperature'] ??
          json['baby_temp'] ??
          json['babyTemperature']),
      babyOxygenLevel: _parseDouble(json['baby_oxygen_level'] ??
          json['oxygen_level'] ??
          json['babyOxygenLevel'] ??
          json['spo2']),
      heartRate:
          _parseInt(json['heart_rate'] ?? json['heartRate'] ?? json['bpm']),
      soundLevel:
          json['sound_level']?.toString() ?? json['soundLevel']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except decimal point and minus
      final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  // Default values for initial state
  factory SensorData.initial() {
    return SensorData(
      temperature: 22.5,
      humidity: 45.0,
      babyTemperature: 36.5,
      babyOxygenLevel: 98.0,
      heartRate: 98,
      soundLevel: 'Normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'baby_temperature': babyTemperature,
      'baby_oxygen_level': babyOxygenLevel,
      'heart_rate': heartRate,
      'sound_level': soundLevel,
    };
  }

  @override
  String toString() {
    return 'SensorData(temp: $temperature, humidity: $humidity, babyTemp: $babyTemperature, oxygen: $babyOxygenLevel, hr: $heartRate, sound: $soundLevel)';
  }
}
