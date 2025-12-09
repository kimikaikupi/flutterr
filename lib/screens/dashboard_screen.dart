import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/sensor_data.dart';
import '../providers/sensor_provider.dart';
import '../utils/status_helper.dart';
import '../widgets/alert_bar.dart';
import '../widgets/floating_particles.dart';
import '../widgets/header_widget.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorProvider>();
    final colors = AppColors(isDark: provider.isDarkMode);
    final sensor = provider.sensorData;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // Floating Particles Background
          Positioned.fill(
            child: FloatingParticles(
              particleColor: Color.fromRGBO(
                colors.primaryGlow.red,
                colors.primaryGlow.green,
                colors.primaryGlow.blue,
                0.4,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  color: colors.primaryGlow,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Dashboard Container
                        _buildDashboardContainer(
                            context, provider, colors, sensor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContainer(
    BuildContext context,
    SensorProvider provider,
    AppColors colors,
    SensorData sensor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              colors.primaryGlow.red,
              colors.primaryGlow.green,
              colors.primaryGlow.blue,
              0.15,
            ),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Top shimmer line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ShimmerLine(color: colors.primaryGlow),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const HeaderWidget(),
                  const SizedBox(height: 24),

                  // Connection Status Banner
                  if (provider.connectionStatus ==
                      ConnectionStatus.disconnected)
                    _buildConnectionError(provider, colors),

                  if (provider.connectionStatus ==
                          ConnectionStatus.connecting &&
                      provider.isLoading)
                    _buildConnectingBanner(colors),

                  // Alert Bar
                  if (provider.hasAlert)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: AlertBar(
                        title: 'Alert: Elevated Temperature',
                        message:
                            "Baby's temperature has exceeded safe threshold. Please check immediately.",
                      ),
                    ),

                  // Metrics Grid
                  _buildMetricsGrid(context, sensor),

                  const SizedBox(height: 32),

                  // Footer
                  _buildFooter(provider, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionError(SensorProvider provider, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 152, 0, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(255, 152, 0, 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connection Lost',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Showing last known data. Tap to retry.',
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingBanner(AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          colors.primaryGlow.red,
          colors.primaryGlow.green,
          colors.primaryGlow.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primaryGlow),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Connecting to sensors...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, SensorData sensor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    if (isDesktop) {
      return _buildDesktopLayout(sensor);
    } else if (isTablet) {
      return _buildTabletLayout(sensor);
    } else {
      return _buildMobileLayout(sensor);
    }
  }

  Widget _buildDesktopLayout(SensorData sensor) {
    return Column(
      children: [
        // Top Row: 2 large cards
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Ambient Temperature',
                value: sensor.temperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat,
                iconColor: Colors.red.shade400,
                iconBgColor: const Color.fromRGBO(244, 67, 54, 0.2),
                statusInfo:
                    StatusHelper.getTemperatureStatus(sensor.temperature),
                progressGradient: [Colors.blue.shade500, Colors.red.shade500],
                idealRange: 'Ideal range: 20-24°C',
                isLarge: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Ambient Humidity',
                value: sensor.humidity.toStringAsFixed(0),
                unit: '%',
                icon: Icons.water_drop,
                iconColor: Colors.blue.shade400,
                iconBgColor: const Color.fromRGBO(33, 150, 243, 0.2),
                statusInfo: StatusHelper.getHumidityStatus(sensor.humidity),
                progressGradient: [Colors.blue.shade600, Colors.cyan.shade400],
                idealRange: 'Ideal range: 40-60%',
                isLarge: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom Row: 3 smaller cards
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Baby Temperature',
                value: sensor.babyTemperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.device_thermostat,
                iconColor: Colors.orange.shade400,
                iconBgColor: const Color.fromRGBO(255, 152, 0, 0.2),
                statusInfo:
                    StatusHelper.getBabyTempStatus(sensor.babyTemperature),
                progressGradient: [Colors.blue.shade500, Colors.red.shade500],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Oxygen Saturation',
                value: sensor.babyOxygenLevel.toStringAsFixed(0),
                unit: '%',
                icon: Icons.air,
                iconColor: Colors.cyan.shade400,
                iconBgColor: const Color.fromRGBO(0, 188, 212, 0.2),
                statusInfo:
                    StatusHelper.getOxygenStatus(sensor.babyOxygenLevel),
                progressGradient: [
                  Colors.purple.shade600,
                  Colors.pink.shade500
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Heart Rate',
                value: sensor.heartRate.toString(),
                unit: ' bpm',
                icon: Icons.favorite,
                iconColor: Colors.pink.shade400,
                iconBgColor: const Color.fromRGBO(233, 30, 99, 0.2),
                statusInfo: StatusHelper.getHeartRateStatus(sensor.heartRate),
                progressGradient: [Colors.pink.shade500, Colors.red.shade500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(SensorData sensor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Ambient Temperature',
                value: sensor.temperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat,
                iconColor: Colors.red.shade400,
                iconBgColor: const Color.fromRGBO(244, 67, 54, 0.2),
                statusInfo:
                    StatusHelper.getTemperatureStatus(sensor.temperature),
                progressGradient: [Colors.blue.shade500, Colors.red.shade500],
                idealRange: 'Ideal range: 20-24°C',
                isLarge: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Ambient Humidity',
                value: sensor.humidity.toStringAsFixed(0),
                unit: '%',
                icon: Icons.water_drop,
                iconColor: Colors.blue.shade400,
                iconBgColor: const Color.fromRGBO(33, 150, 243, 0.2),
                statusInfo: StatusHelper.getHumidityStatus(sensor.humidity),
                progressGradient: [Colors.blue.shade600, Colors.cyan.shade400],
                idealRange: 'Ideal range: 40-60%',
                isLarge: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Baby Temperature',
                value: sensor.babyTemperature.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.device_thermostat,
                iconColor: Colors.orange.shade400,
                iconBgColor: const Color.fromRGBO(255, 152, 0, 0.2),
                statusInfo:
                    StatusHelper.getBabyTempStatus(sensor.babyTemperature),
                progressGradient: [Colors.blue.shade500, Colors.red.shade500],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Oxygen Saturation',
                value: sensor.babyOxygenLevel.toStringAsFixed(0),
                unit: '%',
                icon: Icons.air,
                iconColor: Colors.cyan.shade400,
                iconBgColor: const Color.fromRGBO(0, 188, 212, 0.2),
                statusInfo:
                    StatusHelper.getOxygenStatus(sensor.babyOxygenLevel),
                progressGradient: [
                  Colors.purple.shade600,
                  Colors.pink.shade500
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Heart Rate',
          value: sensor.heartRate.toString(),
          unit: ' bpm',
          icon: Icons.favorite,
          iconColor: Colors.pink.shade400,
          iconBgColor: const Color.fromRGBO(233, 30, 99, 0.2),
          statusInfo: StatusHelper.getHeartRateStatus(sensor.heartRate),
          progressGradient: [Colors.pink.shade500, Colors.red.shade500],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(SensorData sensor) {
    return Column(
      children: [
        MetricCard(
          title: 'Ambient Temperature',
          value: sensor.temperature.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat,
          iconColor: Colors.red.shade400,
          iconBgColor: const Color.fromRGBO(244, 67, 54, 0.2),
          statusInfo: StatusHelper.getTemperatureStatus(sensor.temperature),
          progressGradient: [Colors.blue.shade500, Colors.red.shade500],
          idealRange: 'Ideal range: 20-24°C',
          isLarge: true,
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Ambient Humidity',
          value: sensor.humidity.toStringAsFixed(0),
          unit: '%',
          icon: Icons.water_drop,
          iconColor: Colors.blue.shade400,
          iconBgColor: const Color.fromRGBO(33, 150, 243, 0.2),
          statusInfo: StatusHelper.getHumidityStatus(sensor.humidity),
          progressGradient: [Colors.blue.shade600, Colors.cyan.shade400],
          idealRange: 'Ideal range: 40-60%',
          isLarge: true,
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Baby Temperature',
          value: sensor.babyTemperature.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.device_thermostat,
          iconColor: Colors.orange.shade400,
          iconBgColor: const Color.fromRGBO(255, 152, 0, 0.2),
          statusInfo: StatusHelper.getBabyTempStatus(sensor.babyTemperature),
          progressGradient: [Colors.blue.shade500, Colors.red.shade500],
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Oxygen Saturation',
          value: sensor.babyOxygenLevel.toStringAsFixed(0),
          unit: '%',
          icon: Icons.air,
          iconColor: Colors.cyan.shade400,
          iconBgColor: const Color.fromRGBO(0, 188, 212, 0.2),
          statusInfo: StatusHelper.getOxygenStatus(sensor.babyOxygenLevel),
          progressGradient: [Colors.purple.shade600, Colors.pink.shade500],
        ),
        const SizedBox(height: 16),
        MetricCard(
          title: 'Heart Rate',
          value: sensor.heartRate.toString(),
          unit: ' bpm',
          icon: Icons.favorite,
          iconColor: Colors.pink.shade400,
          iconBgColor: const Color.fromRGBO(233, 30, 99, 0.2),
          statusInfo: StatusHelper.getHeartRateStatus(sensor.heartRate),
          progressGradient: [Colors.pink.shade500, Colors.red.shade500],
        ),
      ],
    );
  }

  Widget _buildFooter(SensorProvider provider, AppColors colors) {
    final hour = provider.lastUpdated.hour.toString().padLeft(2, '0');
    final minute = provider.lastUpdated.minute.toString().padLeft(2, '0');
    final second = provider.lastUpdated.second.toString().padLeft(2, '0');
    final timeString = '$hour:$minute:$second';

    return Column(
      children: [
        Divider(
          color: Color.fromRGBO(
            colors.primaryGlow.red,
            colors.primaryGlow.green,
            colors.primaryGlow.blue,
            0.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2025 Nexus Baby Monitor System | Military-Grade Encryption • Real-time Monitoring',
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Last updated: $timeString',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            ConnectionStatusDot(status: provider.connectionStatus),
          ],
        ),
      ],
    );
  }
}

class ShimmerLine extends StatefulWidget {
  final Color color;

  const ShimmerLine({super.key, required this.color});

  @override
  State<ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<ShimmerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.transparent,
                widget.color,
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConnectionStatusDot extends StatefulWidget {
  final ConnectionStatus status;

  const ConnectionStatusDot({super.key, required this.status});

  @override
  State<ConnectionStatusDot> createState() => _ConnectionStatusDotState();
}

class _ConnectionStatusDotState extends State<ConnectionStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.2),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dotColor,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      _dotColor.red,
                      _dotColor.green,
                      _dotColor.blue,
                      0.5,
                    ),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulseDot extends StatefulWidget {
  final Color color;

  const PulseDot({super.key, required this.color});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.2),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      widget.color.red,
                      widget.color.green,
                      widget.color.blue,
                      0.5,
                    ),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
