import 'package:flutter/material.dart';

import '../config/constants.dart';

enum StatusLevel { optimal, normal, warning, danger }

class StatusInfo {
  final String text;
  final Color color;
  final StatusLevel level;
  final double progressValue;

  StatusInfo({
    required this.text,
    required this.color,
    required this.level,
    required this.progressValue,
  });
}

class StatusHelper {
  static StatusInfo getTemperatureStatus(double temp) {
    if (temp >= 20 && temp <= 24) {
      return StatusInfo(
        text: 'OPTIMAL',
        color: Colors.green,
        level: StatusLevel.optimal,
        progressValue: 0.5,
      );
    } else if (temp > 24 && temp <= Thresholds.roomTempMax) {
      return StatusInfo(
        text: 'WARM',
        color: Colors.yellow.shade700,
        level: StatusLevel.warning,
        progressValue: 0.7,
      );
    } else if (temp < 20 && temp >= Thresholds.roomTempMin) {
      return StatusInfo(
        text: 'COOL',
        color: Colors.blue,
        level: StatusLevel.warning,
        progressValue: 0.3,
      );
    } else {
      return StatusInfo(
        text: 'DANGER',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: temp > Thresholds.roomTempMax ? 0.95 : 0.1,
      );
    }
  }

  static StatusInfo getHumidityStatus(double humidity) {
    if (humidity >= 40 && humidity <= 60) {
      return StatusInfo(
        text: 'OPTIMAL',
        color: Colors.green,
        level: StatusLevel.optimal,
        progressValue: humidity / 100,
      );
    } else if (humidity < Thresholds.humidityMin) {
      return StatusInfo(
        text: 'TOO DRY',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: humidity / 100,
      );
    } else if (humidity > Thresholds.humidityMax) {
      return StatusInfo(
        text: 'TOO HUMID',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: humidity / 100,
      );
    } else {
      return StatusInfo(
        text: 'ACCEPTABLE',
        color: Colors.yellow.shade700,
        level: StatusLevel.warning,
        progressValue: humidity / 100,
      );
    }
  }

  static StatusInfo getBabyTempStatus(double temp) {
    if (temp >= 36 && temp <= 37.5) {
      return StatusInfo(
        text: 'Normal',
        color: Colors.green,
        level: StatusLevel.normal,
        progressValue: 0.65,
      );
    } else if (temp > Thresholds.babyTempMax) {
      return StatusInfo(
        text: 'FEVER!',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: 0.9,
      );
    } else if (temp < Thresholds.babyTempMin) {
      return StatusInfo(
        text: 'Too Low!',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: 0.2,
      );
    } else {
      return StatusInfo(
        text: 'Elevated',
        color: Colors.yellow.shade700,
        level: StatusLevel.warning,
        progressValue: 0.75,
      );
    }
  }

  static StatusInfo getOxygenStatus(double oxygen) {
    if (oxygen >= 98) {
      return StatusInfo(
        text: 'Excellent',
        color: Colors.green,
        level: StatusLevel.optimal,
        progressValue: oxygen / 100,
      );
    } else if (oxygen >= Thresholds.babyOxygenMin) {
      return StatusInfo(
        text: 'Normal',
        color: Colors.green,
        level: StatusLevel.normal,
        progressValue: oxygen / 100,
      );
    } else {
      return StatusInfo(
        text: 'CRITICAL!',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: oxygen / 100,
      );
    }
  }

  static StatusInfo getHeartRateStatus(int hr) {
    if (hr >= 80 && hr <= 140) {
      return StatusInfo(
        text: 'Stable',
        color: Colors.green,
        level: StatusLevel.normal,
        progressValue: 0.75,
      );
    } else if (hr < Thresholds.heartRateMin || hr > Thresholds.heartRateMax) {
      return StatusInfo(
        text: 'ABNORMAL!',
        color: Colors.red,
        level: StatusLevel.danger,
        progressValue: hr < Thresholds.heartRateMin ? 0.2 : 0.95,
      );
    } else {
      return StatusInfo(
        text: 'Elevated',
        color: Colors.yellow.shade700,
        level: StatusLevel.warning,
        progressValue: 0.6,
      );
    }
  }
}
