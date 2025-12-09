import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/sensor_data.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<SensorData?> fetchSensorData() async {
    try {
      developer.log('Fetching from: ${ApiConstants.fetchSensorsUrl}',
          name: 'ApiService');

      final response = await _client.get(
        Uri.parse(ApiConstants.fetchSensorsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      developer.log('Response status: ${response.statusCode}',
          name: 'ApiService');
      developer.log('Response body: ${response.body}', name: 'ApiService');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        // Handle different response formats
        Map<String, dynamic>? data;

        if (decoded is Map<String, dynamic>) {
          // Format 1: { "success": true, "data": { ... } }
          if (decoded.containsKey('success') && decoded['success'] == true) {
            if (decoded['data'] is Map<String, dynamic>) {
              data = decoded['data'];
            } else if (decoded['data'] is List &&
                (decoded['data'] as List).isNotEmpty) {
              data = (decoded['data'] as List).first;
            }
          }
          // Format 2: { "status": "success", "data": { ... } }
          else if (decoded.containsKey('status') &&
              decoded['status'] == 'success') {
            if (decoded['data'] is Map<String, dynamic>) {
              data = decoded['data'];
            } else if (decoded['data'] is List &&
                (decoded['data'] as List).isNotEmpty) {
              data = (decoded['data'] as List).first;
            }
          }
          // Format 3: Direct data object { "temperature": 25, ... }
          else if (decoded.containsKey('temperature') ||
              decoded.containsKey('humidity') ||
              decoded.containsKey('heart_rate')) {
            data = decoded;
          }
          // Format 4: { "result": { ... } }
          else if (decoded.containsKey('result') &&
              decoded['result'] is Map<String, dynamic>) {
            data = decoded['result'];
          }
        }
        // Format 5: Array response [{ ... }]
        else if (decoded is List && decoded.isNotEmpty) {
          data = decoded.first;
        }

        if (data != null) {
          final sensorData = SensorData.fromJson(data);
          developer.log('Parsed sensor data: $sensorData', name: 'ApiService');
          return sensorData;
        } else {
          developer.log('Could not parse data from response: $decoded',
              name: 'ApiService');
          return null;
        }
      } else {
        developer.log('HTTP Error: ${response.statusCode} - ${response.body}',
            name: 'ApiService');
        return null;
      }
    } on TimeoutException {
      developer.log('Request timeout', name: 'ApiService');
      return null;
    } on FormatException catch (e) {
      developer.log('JSON parsing error: $e', name: 'ApiService');
      return null;
    } catch (e, stackTrace) {
      developer.log('Failed to fetch sensor data: $e', name: 'ApiService');
      developer.log('Stack trace: $stackTrace', name: 'ApiService');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
