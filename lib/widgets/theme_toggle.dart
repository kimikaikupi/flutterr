import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sensor_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final isDark = provider.isDarkMode;

    return GestureDetector(
      onTap: () => provider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF87CEEB), const Color(0xFFE0F6FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF9D4EDD).withValues(alpha: 0.3)
                  : const Color(0xFFF39C12).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icons
            Positioned(
              left: 8,
              top: 8,
              child: Icon(
                Icons.nightlight_round,
                size: 16,
                color: isDark
                    ? const Color(0xFFF1C40F)
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Icon(
                Icons.wb_sunny,
                size: 16,
                color: !isDark
                    ? const Color(0xFFF39C12)
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            // Sliding circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 4 : 32,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
