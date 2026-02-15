import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

void main() {
  runApp(const ProviderScope(child: ArcticApp()));
}

// ============ PROVIDERS ============

enum VpnStatus { disconnected, connecting, connected }

class VpnState {
  final VpnStatus status;
  final int seconds;
  final double speed;
  
  VpnState({required this.status, this.seconds = 0, this.speed = 0.0});
  
  VpnState copyWith({VpnStatus? status, int? seconds, double? speed}) =>
      VpnState(status: status ?? this.status, seconds: seconds ?? this.seconds, speed: speed ?? this.speed);
}

class VpnNotifier extends StateNotifier<VpnState> {
  Timer? _timer;
  VpnNotifier() : super(VpnState(status: VpnStatus.disconnected));

  Future<void> connect() async {
    state = state.copyWith(status: VpnStatus.connecting);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(status: VpnStatus.connected, speed: 127.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(seconds: state.seconds + 1);
    });
  }

  void disconnect() {
    _timer?.cancel();
    state = VpnState(status: VpnStatus.disconnected);
  }
}

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnState>((ref) => VpnNotifier());

class SettingsState {
  final String protocol;
  final bool autoConnect;
  final bool darkTheme;
  
  SettingsState({this.protocol = 'WireGuard', this.autoConnect = false, this.darkTheme = false});
  
  SettingsState copyWith({String? protocol, bool? autoConnect, bool? darkTheme}) =>
      SettingsState(
        protocol: protocol ?? this.protocol,
        autoConnect: autoConnect ?? this.autoConnect,
        darkTheme: darkTheme ?? this.darkTheme,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());
  
  void setProtocol(String p) => state = state.copyWith(protocol: p);
  void toggleAuto() => state = state.copyWith(autoConnect: !state.autoConnect);
  void toggleDark() => state = state.copyWith(darkTheme: !state.darkTheme);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());

// ============ APP ============

class ArcticApp extends ConsumerWidget {
  const ArcticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(settingsProvider).darkTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFF2F2F7)),
      darkTheme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF000000)),
      home: const HomeScreen(),
    );
  }
}

// ============ HOME ============

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpn = ref.watch(vpnProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('ARCTIC VPN', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConnectionButton(
                            status: vpn.status,
                            onTap: () {
                              if (vpn.status == VpnStatus.connected) {
                                ref.read(vpnProvider.notifier).disconnect();
                              } else if (vpn.status == VpnStatus.disconnected) {
                                ref.read(vpnProvider.notifier).connect();
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${(vpn.seconds ~/ 60).toString().padLeft(2, '0')}:${(vpn.seconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: StatsCard(label: 'СКОРОСТЬ', value: '${vpn.speed.toInt()} мбит/с')),
                      const SizedBox(width: 16),
                      const Expanded(child: StatsCard(label: 'ДО', value: '13.04')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(child: Text('ID: 4829105736', style: TextStyle(color: Colors.grey.shade600))),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 24,
              child: GestureDetector(
                onTap: () => showQuickMenu(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.settings_outlined, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ WIDGETS ============

class ConnectionButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;

  const ConnectionButton({super.key, required this.status, required this.onTap});

  @override
  State<ConnectionButton> createState() => _ConnectionButtonState();
}

class _ConnectionButtonState extends State<ConnectionButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.status == VpnStatus.connecting) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: widget.status == VpnStatus.connected
                  ? const Color(0xFF5AC8FA).withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Center(
              child: widget.status == VpnStatus.connecting
                  ? AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, child) => Transform.rotate(
                        angle: _ctrl.value * 2 * math.pi,
                        child: child,
                      ),
                      child: const SnowflakeIcon(size: 80, color: Color(0xFF5AC8FA)),
                    )
                  : Icon(
                      widget.status == VpnStatus.connected ? Icons.shield : Icons.power_settings_new,
                      size: 80,
                      color: widget.status == VpnStatus.connected
                          ? const Color(0xFF34C759)
                          : Colors.grey.withOpacity(0.5),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnowflakeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SnowflakeIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: SnowflakePainter(color: color));
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
      canvas.drawLine(
        center,
        Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatsCard extends StatelessWidget {
  final String label;
  final String value;

  const StatsCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(isDark ? 0.1 : 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ MENUS ============

void showQuickMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const QuickMenu(),
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
          color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuItem(title: 'Протокол', onTap: () { Navigator.pop(context); showProtocolDialog(context, ref); }),
            const Divider(height: 1),
            MenuItem(title: 'Безопасность', onTap: () { Navigator.pop(context); showInfo(context, 'Безопасность', '🔒 AES-256\n🛡️ DNS Protection\n🔐 PFS'); }),
            const Divider(height: 1),
            MenuItem(title: 'О подписке', onTap: () { Navigator.pop(context); showInfo(context, 'Подписка', '📅 Premium\n⏰ До: 15.03.2026\n💎 Безлимит'); }),
            const Divider(height: 1),
            MenuItem(title: 'О приложении', onTap: () { Navigator.pop(context); showAboutDialog(context: context, applicationName: 'Arctic VPN', applicationVersion: '1.0.0'); }),
            const Divider(height: 1),
            MenuItem(title: 'Больше', trailing: const Icon(Icons.chevron_right), onTap: () { Navigator.pop(context); showFullSettings(context); }),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const MenuItem({super.key, required this.title, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17))),
            if (trailing != null) trailing!,
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
    builder: (_) => const FullSettings(),
  );
}

class FullSettings extends ConsumerWidget {
  const FullSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF1C1C1E) : Colors.white).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Полные настройки', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SettingItem(icon: '🌐', title: 'Протокол', subtitle: settings.protocol, onTap: () => showProtocolDialog(context, ref)),
              SettingItem(icon: '🛡️', title: 'Безопасность', onTap: () => showInfo(context, 'Безопасность', '🔒 AES-256')),
              SettingItem(icon: '💳', title: 'О подписке', onTap: () => showInfo(context, 'Подписка', '📅 Premium')),
              SettingItem(icon: '🖥️', title: 'Серверы', subtitle: 'США - NY', onTap: () {}),
              SettingItem(icon: '🔒', title: 'Шифрование', subtitle: 'AES-256', onTap: () {}),
              SettingItem(icon: '📄', title: 'Логи', onTap: () => showInfo(context, 'Логи', '14:30 US-NY\n12:15 Disconnected')),
              ToggleItem(icon: '⚡', title: 'Автоподключение', value: settings.autoConnect, onChanged: (_) => ref.read(settingsProvider.notifier).toggleAuto()),
              ToggleItem(icon: '🌙', title: 'Тёмная тема', value: settings.darkTheme, onChanged: (_) => ref.read(settingsProvider.notifier).toggleDark()),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingItem({super.key, required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5))),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17)),
                  if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFC7C7CC)),
          ],
        ),
      ),
    );
  }
}

class ToggleItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleItem({super.key, required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5))),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17))),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 51,
              height: 31,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: value ? const Color(0xFF34C759) : const Color(0xFFE5E5EA),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 27,
                  height: 27,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ DIALOGS ============

void showProtocolDialog(BuildContext context, WidgetRef ref) {
  final settings = ref.read(settingsProvider);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Выбрать протокол'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in ['WireGuard', 'OpenVPN', 'IKEv2'])
            InkWell(
              onTap: () {
                ref.read(settingsProvider.notifier).setProtocol(p);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(p)),
                    if (settings.protocol == p) const Icon(Icons.check, color: Colors.blue),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
void showInfo(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Text(content, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

