import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

void main() {
  runApp(const ProviderScope(child: ArcticApp()));
}

/// ================ PROVIDERS ================

// VPN состояние
enum VpnStatus { disconnected, connecting, connected }

class VpnState {
  final VpnStatus status;
  final int connectionSeconds;
  final double speed;
  
  VpnState({
    required this.status,
    this.connectionSeconds = 0,
    this.speed = 0.0,
  });
  
  VpnState copyWith({VpnStatus? status, int? connectionSeconds, double? speed}) {
    return VpnState(
      status: status ?? this.status,
      connectionSeconds: connectionSeconds ?? this.connectionSeconds,
      speed: speed ?? this.speed,
    );
  }
}

class VpnNotifier extends StateNotifier<VpnState> {
  Timer? _timer;
  
  VpnNotifier() : super(VpnState(status: VpnStatus.disconnected));

  Future<void> connect() async {
    state = state.copyWith(status: VpnStatus.connecting);
    
    // Имитация подключения
    await Future.delayed(const Duration(seconds: 2));
    
    state = state.copyWith(
      status: VpnStatus.connected,
      speed: 127.0,
    );
    
    // Запуск таймера
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(
        connectionSeconds: state.connectionSeconds + 1,
      );
    });
  }

  void disconnect() {
    _timer?.cancel();
    state = VpnState(status: VpnStatus.disconnected);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnState>((ref) {
  return VpnNotifier();
});

// Настройки
class SettingsState {
  final String protocol;
  final bool autoConnect;
  final bool darkTheme;
  final bool killSwitch;
  
  SettingsState({
    this.protocol = 'WireGuard',
    this.autoConnect = false,
    this.darkTheme = false,
    this.killSwitch = true,
  });
  
  SettingsState copyWith({
    String? protocol,
    bool? autoConnect,
    bool? darkTheme,
    bool? killSwitch,
  }) {
    return SettingsState(
      protocol: protocol ?? this.protocol,
      autoConnect: autoConnect ?? this.autoConnect,
      darkTheme: darkTheme ?? this.darkTheme,
      killSwitch: killSwitch ?? this.killSwitch,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());
  
  void setProtocol(String protocol) {
    state = state.copyWith(protocol: protocol);
  }
  
  void toggleAutoConnect() {
    state = state.copyWith(autoConnect: !state.autoConnect);
  }
  
  void toggleDarkTheme() {
    state = state.copyWith(darkTheme: !state.darkTheme);
  }
  
  void toggleKillSwitch() {
    state = state.copyWith(killSwitch: !state.killSwitch);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// ================ APP ================

class ArcticApp extends ConsumerWidget {
  const ArcticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.darkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeScreen(),
    );
  }
}

/// ================ HOME SCREEN ================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Заголовок
                  const Text(
                    "ARCTIC VPN",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Кнопка и таймер
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConnectionButton(
                            status: vpnState.status,
                            onTap: () {
                              if (vpnState.status == VpnStatus.connected) {
                                ref.read(vpnProvider.notifier).disconnect();
                              } else if (vpnState.status == VpnStatus.disconnected) {
                                ref.read(vpnProvider.notifier).connect();
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _formatTime(vpnState.connectionSeconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Статистика
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'СКОРОСТЬ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${vpnState.speed.toInt()} мбит/с',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ДО',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '13.04',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ID
                  Center(
                    child: Text(
                      'ID: 4829105736',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Шестерёнка
            Positioned(
              top: 20,
              right: 24,
              child: GestureDetector(
                onTap: () => showQuickMenu(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

/// ================ CONNECTION BUTTON ================

class ConnectionButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;

  const ConnectionButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<ConnectionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.status == VpnStatus.connecting) {
      _controller.repeat();
    } else {
      _controller.stop();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? const Color(0xFF1C1C1E).withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: widget.status == VpnStatus.connected
                  ? const Color(0xFF5AC8FA).withOpacity(0.3)
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: widget.status == VpnStatus.connecting
                    ? AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: const SnowflakeIcon(
                          size: 80,
                          color: Color(0xFF5AC8FA),
                        ),
                      )
                    : Icon(
                        widget.status == VpnStatus.connected
                            ? Icons.shield
                            : Icons.power_settings_new,
                        size: 80,
                        color: widget.status == VpnStatus.connected
                            ? const Color(0xFF34C759)
                            : Colors.grey.withOpacity(0.5),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================ SNOWFLAKE ICON ================

class SnowflakeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SnowflakeIcon({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SnowflakePainter(color: color),
    );
  }
}

class SnowflakePainter extends CustomPainter {
  final Color color;

  SnowflakePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(endX, endY), paint);
      
      final branchLength = radius * 0.3;
      for (double t in [0.5, 0.7]) {
        final branchX = center.dx + (radius * t) * math.cos(angle);
        final branchY = center.dy + (radius * t) * math.sin(angle);
        
        final leftAngle = angle - math.pi / 6;
        canvas.drawLine(
          Offset(branchX, branchY),
          Offset(
            branchX + branchLength * math.cos(leftAngle),
            branchY + branchLength * math.sin(leftAngle),
          ),
          paint,
        );
        
        final rightAngle = angle + math.pi / 6;
        canvas.drawLine(
          Offset(branchX, branchY),
          Offset(
            branchX + branchLength * math.cos(rightAngle),
            branchY + branchLength * math.sin(rightAngle),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SnowflakePainter oldDelegate) => false;
}

/// ================ GLASS CARD ================

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withOpacity(0.7)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ================ MENUS ================

void showQuickMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuickMenu(),
  );
}

class QuickMenu extends ConsumerWidget {
  const QuickMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(
              title: 'Протокол',
              onTap: () {
                Navigator.pop(context);
                showProtocolDialog(context);
              },
            ),
            const Divider(height: 1),
            _MenuItem(
              title: 'Безопасность',
              onTap: () {
                Navigator.pop(context);
                showSecuritySheet(context);
              },
            ),
            const Divider(height: 1),
            _MenuItem(
              title: 'О подписке',
              onTap: () {
                Navigator.pop(context);
                showSubscriptionSheet(context);
              },
            ),
            const Divider(height: 1),
            _MenuItem(
              title: 'О приложении',
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Arctic VPN',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.ac_unit, size: 48),
                );
              },
            ),
            const Divider(height: 1),
            _MenuItem(
              title: 'Больше',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.pop(context);
                showFullSettings(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

void showFullSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const FullSettingsSheet(),
  );
}

class FullSettingsSheet extends ConsumerWidget {
  const FullSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                