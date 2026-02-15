import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_screen.dart';

// ============================================================================
// ПРОВАЙДЕРЫ STATE
// ============================================================================

// Провайдер для статуса подключения
final connectionStatusProvider = StateProvider<bool>((ref) => false);

// Провайдер для таймера подключения (секунды)
final connectionTimerProvider = StateProvider<int>((ref) => 14);

// Провайдер для скорости (мбит/с)
final speedProvider = StateProvider<double>((ref) => 0.0);

// ============================================================================
// ГЛАВНЫЙ ЭКРАН ПРИЛОЖЕНИЯ
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Контроллер для вращения снежинки
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // Контроллер для пульсации снежинки
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final connectionTimer = ref.watch(connectionTimerProvider);
    final speed = ref.watch(speedProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black, // Базовый чёрный фон
      child: Stack(
        children: [
          // ===================================================================
          // ГРАДИЕНТНЫЙ ФОН (тёмно-синий → чёрный)
          // ===================================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A1929), // Тёмно-синий сверху
                    Color(0xFF000000), // Чёрный снизу
                  ],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          
          // ===================================================================
          // ЗАГОЛОВОК "ARCTIC VPN" (верхний левый угол)
          // ===================================================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 24,
            child: const Text(
              'ARCTIC VPN',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          // ===================================================================
          // КНОПКА НАСТРОЕК (шестерёнка, правый верхний угол)
          // ===================================================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 44,
              onPressed: () {
                // Открываем модальное окно настроек
                SettingsScreen.show(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.gear_alt_fill,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // ===================================================================
          // ЦЕНТРАЛЬНАЯ ЧАСТЬ: СНЕЖИНКА + ТАЙМЕР
          // ===================================================================
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ГОЛУБАЯ СНЕЖИНКА (вращение + пульсация)
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    final rotationValue = _rotationController.value;
                    final pulseValue = _pulseController.value;
                    final scale = 1.0 + (pulseValue * 0.1); // 1.0 → 1.1
                    
                    return Transform.rotate(
                      angle: rotationValue * 2 * math.pi,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.white.withOpacity(0.08),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BFA5).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.snow,
                            size: 90,
                            color: Color(0xFF64B5F6), // Голубой
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // ТАЙМЕР ПОДКЛЮЧЕНИЯ (00:14)
                Text(
                  _formatTimer(connectionTimer),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // ===================================================================
          // НИЖНЯЯ ПАНЕЛЬ: ДВЕ БЕЛЫЕ КАПСУЛЬНЫЕ КАРТОЧКИ
          // ===================================================================
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Левая карточка: СКОРОСТЬ
                Expanded(
                  child: _buildSpeedCard(
                    label: 'СКОРОСТЬ',
                    value: '${speed.toStringAsFixed(0)} мбит/с',
                    icon: CupertinoIcons.arrow_down,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Правая карточка: ДО
                Expanded(
                  child: _buildSpeedCard(
                    label: 'ДО',
                    value: '13.04',
                    icon: CupertinoIcons.calendar,
                  ),
                ),
              ],
            ),
          ),
          
          // ===================================================================
          // ID ВНИЗУ (самый низ экрана)
          // ===================================================================
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'ID: 4829105736',
                style: TextStyle(
                  color: CupertinoColors.systemGrey.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // БЕЛАЯ КАПСУЛЬНАЯ КАРТОЧКА (с эффектом выпуклости)
  // ===========================================================================
  Widget _buildSpeedCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        // БЕЛЫЙ фон
        color: CupertinoColors.white,
        // КАПСУЛЬНАЯ форма (сильное закругление)
        borderRadius: BorderRadius.circular(24),
        // ТЕНИ для выпуклости
        boxShadow: [
          // Основная тень снизу
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          // Светлая подсветка сверху (inner glow эффект)
          BoxShadow(
            color: CupertinoColors.white.withOpacity(0.9),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
        // Лёгкий градиент для объёма
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.white,
            const Color(0xFFF8F8F8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Лейбл (СКОРОСТЬ / ДО)
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.systemGrey.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Значение (0 мбит/с / 13.04)
          Row(
            children: [
              // Иконка (только для скорости)
              if (label == 'СКОРОСТЬ')
                Icon(
                  icon,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
              if (label == 'СКОРОСТЬ') const SizedBox(width: 8),
              
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
    // LOOP АНИМАЦИЯ: лёгкая пульсация + glow
    .animate(
      onPlay: (controller) => controller.repeat(),
    )
    .scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.02, 1.02),
      duration: 2200.ms,
      curve: Curves.easeInOut,
    )
    .then()
    .scale(
      begin: const Offset(1.02, 1.02),
      end: const Offset(1.0, 1.0),
      duration: 2200.ms,
      curve: Curves.easeInOut,
    );
  }

  // ===========================================================================
  // ФОРМАТИРОВАНИЕ ТАЙМЕРА (секунды → MM:SS)
  // ===========================================================================
  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
