import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/sensor_provider.dart';
import '../utils/status_helper.dart';

class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final StatusInfo statusInfo;
  final List<Color> progressGradient;
  final String? idealRange;
  final bool isLarge;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.statusInfo,
    required this.progressGradient,
    this.idealRange,
    this.isLarge = false,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final colors = AppColors(isDark: provider.isDarkMode);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: colors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered ? colors.primaryGlow : colors.borderLight,
                  width: _isHovered ? 1.5 : 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: colors.primaryGlow.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              colors.primaryGlow.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(widget.isLarge ? 28 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title.toUpperCase(),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: widget.isLarge ? 14 : 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              _buildIconContainer(),
                            ],
                          ),
                          SizedBox(height: widget.isLarge ? 20 : 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    colors.textPrimary,
                                    colors.primaryGlow,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  '${widget.value}${widget.unit}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: widget.isLarge ? 40 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(colors),
                          if (widget.idealRange != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.idealRange!,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: widget.isLarge ? 60 : 48,
      height: widget.isLarge ? 60 : 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.iconBgColor,
      ),
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: widget.isLarge ? 28 : 22,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isDanger = widget.statusInfo.level == StatusLevel.danger;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.statusInfo.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDanger)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.5),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.statusInfo.color,
                ),
              ),
            ),
          if (isDanger) const SizedBox(width: 4),
          Text(
            widget.statusInfo.text,
            style: GoogleFonts.robotoMono(
              color: widget.statusInfo.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColors colors) {
    return Column(
      children: [
        Container(
          height: widget.isLarge ? 8 : 6,
          decoration: BoxDecoration(
            color: colors.textMuted.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width:
                        constraints.maxWidth * widget.statusInfo.progressValue,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.progressGradient,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: widget.progressGradient.last
                              .withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
