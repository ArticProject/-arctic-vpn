import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_screen.dart';

final connectionTimerProvider = StateProvider<int>((ref) => 14);
final speedProvider = StateProvider<double>((ref) => 0.0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    
    // ROTATION (медленное вращение)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    // PULSE (scale 1.0 → 1.12)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    // GLOW (тень)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(connectionTimerProvider);
    final speed = ref.watch(speedProvider);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      child: Stack(
        children: [
          // ARCTIC VPN
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: const Text(
              'ARCTIC VPN',
              style: TextStyle(
                color: CupertinoColors.black,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontFamily: '.SF Pro Display',
              ),
            ),
          ),
          
          // ШЕСТЕРЁНКА
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _TappableButton(
              onPressed: () => SettingsScreen.show(context),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF3A3A3C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.gear_alt_fill,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // СНЕЖИНКА (rotation + pulse + glow)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _pulseController,
                    _glowController,
                  ]),
                  builder: (context, child) {
                    final rotation = _rotationController.value * 0.05; // 0 → 0.05 rad
                    final pulse = _pulseController.value;
                    final scale = 1.0 + (pulse * 0.12); // 1.0 → 1.12
                    final glowOpacity = 0.1 + (_glowController.value * 0.2);
                    
                    return Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white,
                            boxShadow: [
                              // NEUMORPHISM тени
                              BoxShadow(
                                color: CupertinoColors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: CupertinoColors.white.withOpacity(0.9),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                              // ANIMATED GLOW
                              BoxShadow(
                                color: const Color(0xFF64B5F6).withOpacity(glowOpacity),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.snow,
                            size: 96,
                            color: Color(0xFF64B5F6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                Text(
                  _formatTimer(timer),
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 68,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 3,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
          
          // ID
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 180,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'ID: 4829105736',
                style: TextStyle(
                  color: CupertinoColors.systemGrey.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: '.SF Pro Text',
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          
          // КАРТОЧКИ (с tap-анимациями)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: _TappableCard(
                    child: _buildCard('СКОРОСТЬ', '${speed.toStringAsFixed(0)} мбит/с', true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TappableCard(
                    child: _buildCard('ДО', '13.04', false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String label, String value, bool icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CupertinoColors.white, Color(0xFFFAFAFA)],
        ),
        // CAPSULE ФОРМА (pill shape)
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(4, 6),
          ),
          BoxShadow(
            color: CupertinoColors.white.withOpacity(0.9),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.systemGrey.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontFamily: '.SF Pro Text',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon) ...[
                Icon(
                  CupertinoIcons.arrow_down,
                  size: 18,
                  color: CupertinoColors.systemGrey.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// TAP-АНИМАЦИЯ ДЛЯ КАРТОЧЕК (scale 1.0 → 0.96 + glow)
class _TappableCard extends StatefulWidget {
  final Widget child;
  const _TappableCard({required this.child});

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// TAP-АНИМАЦИЯ ДЛЯ КНОПОК
class _TappableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  const _TappableButton({required this.child, required this.onPressed});

  @override
  State<_TappableButton> createState() => _TappableButtonState();
}

class _TappableButtonState extends State<_TappableButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
