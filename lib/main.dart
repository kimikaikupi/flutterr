import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/sensor_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const BabyMonitorApp());
}

class BabyMonitorApp extends StatelessWidget {
  const BabyMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
      ],
      child: Consumer<SensorProvider>(
        builder: (context, sensorProvider, child) {
          return MaterialApp(
            title: 'Nexus Baby Monitor',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primaryColor: const Color(0xFF7B2CBF),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF7B2CBF),
                secondary: Color(0xFF5A189A),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF9D4EDD),
              scaffoldBackgroundColor: const Color(0xFF0F0F1A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF9D4EDD),
                secondary: Color(0xFF5E2CA5),
              ),
            ),
            themeMode:
                sensorProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
