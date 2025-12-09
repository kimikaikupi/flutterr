import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/sensor_provider.dart';
import 'theme_toggle.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  Color _withAlpha(Color color, double opacity) {
    return Color.fromRGBO(color.red, color.green, color.blue, opacity);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final colors = AppColors(isDark: provider.isDarkMode);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildResponsiveHeader(context, colors, screenWidth),
        const SizedBox(height: 16),
        Divider(color: _withAlpha(colors.primaryGlow, 0.3)),
      ],
    );
  }

  Widget _buildResponsiveHeader(
      BuildContext context, AppColors colors, double screenWidth) {
    // Extra small screens (< 400)
    if (screenWidth < 400) {
      return _buildExtraSmallHeader(colors);
    }
    // Small screens (400 - 600)
    else if (screenWidth < 600) {
      return _buildSmallHeader(colors);
    }
    // Medium screens (600 - 900)
    else if (screenWidth < 900) {
      return _buildMediumHeader(colors);
    }
    // Large screens (>= 900)
    else {
      return _buildLargeHeader(colors);
    }
  }

  Widget _buildExtraSmallHeader(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo and Theme Toggle Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCompactLogo(colors),
            const ThemeToggle(),
          ],
        ),
        const SizedBox(height: 12),
        // Live indicator
        _buildLiveIndicator(),
        const SizedBox(height: 12),
        // Navigation as wrap
        _buildCompactNavigation(colors),
      ],
    );
  }

  Widget _buildSmallHeader(AppColors colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _buildLogo(colors, compact: true)),
            const SizedBox(width: 8),
            const ThemeToggle(),
          ],
        ),
        const SizedBox(height: 12),
        _buildCompactNavigation(colors),
      ],
    );
  }

  Widget _buildMediumHeader(AppColors colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: _buildLogo(colors, compact: false)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserBadge(colors, compact: true),
                const SizedBox(width: 12),
                const ThemeToggle(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNavigation(colors),
      ],
    );
  }

  Widget _buildLargeHeader(AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(flex: 2, child: _buildLogo(colors, compact: false)),
        Flexible(flex: 3, child: Center(child: _buildNavigation(colors))),
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _buildUserBadge(colors, compact: false)),
              const SizedBox(width: 16),
              const ThemeToggle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLogo(AppColors colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _withAlpha(colors.primaryGlow, 0.2),
          ),
          child: Icon(
            Icons.child_care,
            size: 24,
            color: colors.primaryGlow,
          ),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colors.textPrimary,
              colors.primaryGlow,
            ],
          ).createShader(bounds),
          child: Text(
            'BABY CARE',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 255, 0, 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'LIVE',
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(AppColors colors, {required bool compact}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: compact ? 42 : 50,
              height: compact ? 42 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _withAlpha(colors.primaryGlow, 0.2),
              ),
            ),
            Icon(
              Icons.child_care,
              size: compact ? 26 : 32,
              color: colors.primaryGlow,
            ),
          ],
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    colors.textPrimary,
                    colors.primaryGlow,
                    colors.secondaryGlow,
                  ],
                ).createShader(bounds),
                child: Text(
                  'BABY CARE',
                  style: GoogleFonts.orbitron(
                    fontSize: compact ? 18 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: _withAlpha(Colors.green, 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      compact ? 'LIVE' : 'LIVE • REAL-TIME',
                      style: GoogleFonts.robotoMono(
                        fontSize: 9,
                        color: Colors.green,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNavigation(AppColors colors) {
    final items = ['Dashboard', 'Live', 'Mic', 'Chat'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: items.map((item) {
        final isActive = item == 'Dashboard';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? _withAlpha(colors.primaryGlow, 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? colors.primaryGlow : colors.borderLight,
              width: 1,
            ),
          ),
          child: Text(
            item,
            style: TextStyle(
              color: isActive ? colors.textPrimary : colors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigation(AppColors colors) {
    final items = ['Dashboard', 'Live Feed', 'Mic', 'Chat'];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => _buildNavItem(item, colors, item == 'Dashboard'))
          .toList(),
    );
  }

  Widget _buildNavItem(String title, AppColors colors, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? colors.textPrimary : colors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: isActive ? 30 : 0,
            decoration: BoxDecoration(
              color: colors.primaryGlow,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBadge(AppColors colors, {required bool compact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            color: colors.primaryGlow,
            size: compact ? 14 : 18,
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            Text(
              'Parent',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
