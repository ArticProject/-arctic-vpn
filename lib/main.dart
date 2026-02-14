import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: ArcticApp()));
}

/// ---------------- APP ----------------

class ArcticApp extends StatelessWidget {
  const ArcticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// ---------------- PROVIDER ----------------

final vpnProvider =
    StateNotifierProvider<VpnNotifier, bool>((ref) => VpnNotifier());

class VpnNotifier extends StateNotifier<bool> {
  VpnNotifier() : super(false);

  void toggle() => state = !state;
}

/// ---------------- HOME SCREEN ----------------

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(vpnProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// Контент
            Column(
              children: [
                const SizedBox(height: 20),

                /// Заголовок
                const Text(
                  "ARCTIC VPN",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                /// Кнопка
                ArcticPowerButton(
                  isConnected: isConnected,
                  onTap: () =>
                      ref.read(vpnProvider.notifier).toggle(),
                ),

                const SizedBox(height: 40),

                Text(
                  isConnected ? "CONNECTED" : "DISCONNECTED",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                const Text(
                  "ID: 4829105736",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),

            /// Шестерёнка
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  size: 28,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // Здесь позже подключим overlay popup
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- POWER BUTTON ----------------

class ArcticPowerButton extends StatefulWidget {
  final bool isConnected;
  final VoidCallback onTap;

  const ArcticPowerButton({
    super.key,
    required this.isConnected,
    required this.onTap,
  });

  @override
  State<ArcticPowerButton> createState() =>
      _ArcticPowerButtonState();
}

class _ArcticPowerButtonState extends State<ArcticPowerButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// Внешний круг
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(12, 12),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 30,
                          offset: const Offset(-12, -12),
                        ),
                      ],
              ),
            ),

            /// Внутренний круг
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF2C2C2E),
                          Color(0xFF1C1C1E),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFEAEAF0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: widget.isConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4FC3F7)
                              .withOpacity(0.45),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
            ),

            /// Иконка
            AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: pressed ? 0.95 : 1,
              child: Icon(
                Icons.ac_unit,
                size: 64,
                color: widget.isConnected
                    ? const Color(0xFF4FC3F7)
                    : (isDark
                        ? Colors.grey.shade400
                        : Colors.blueGrey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
