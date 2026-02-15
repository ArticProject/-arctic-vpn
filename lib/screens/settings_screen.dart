import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// ПРОВАЙДЕРЫ STATE (Riverpod)
// ============================================================================

// Провайдер для Автоподключения
final autoConnectProvider = StateProvider<bool>((ref) => false);

// Провайдер для Темной темы
final darkThemeProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// ГЛАВНЫЙ ВИДЖЕТ МОДАЛЬНОГО ОКНА НАСТРОЕК
// ============================================================================

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Функция для открытия модалки
  static Future<void> show(BuildContext context) {
    return showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.3),
      builder: (BuildContext context) => const SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
      children: [
        // BACKDROP FILTER — сильный blur для фона (sigma 12-15)
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
              child: Container(
                color: CupertinoColors.black.withOpacity(0.25),
              ),
            ),
          ),
        ),
        
        // МОДАЛЬНЫЙ КОНТЕЙНЕР С НАСТРОЙКАМИ
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Блокируем закрытие при тапе на контент
            child: Container(
              // Отступы от краёв экрана 16px
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: screenWidth - 32,
              height: screenHeight * 0.78, // ~78% высоты экрана
              
              decoration: BoxDecoration(
                // СВЕТЛЫЙ фон для светлой темы #F2F2F7 (iOS grouped background)
                color: const Color(0xFFF2F2F7),
                // ОЧЕНЬ сильное закругление углов (32-36px) на ВСЕХ углах
                borderRadius: BorderRadius.circular(36),
                // Лёгкая тень для глубины
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              
              // ClipRRect для обрезки контента по rounded corners
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  children: [
                    // ОСНОВНОЙ КОНТЕНТ (список настроек)
                    Column(
                      children: [
                        // ЗАГОЛОВОК
                        _buildHeader(context),
                        
                        // СПИСОК НАСТРОЕК (с анимацией появления)
                        Expanded(
                          child: _buildSettingsList(ref),
                        ),
                      ],
                    ),
                    
                    // НИЖНЯЯ ФИКСИРОВАННАЯ ПАНЕЛЬ (не скроллится)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomPanel(),
                    ),
                  ],
                ),
              ),
            )
            // Анимация появления модалки: slide up + fade + scale
            .animate()
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 450.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 350.ms)
            .scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1.0, 1.0),
              duration: 450.ms,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ЗАГОЛОВОК МОДАЛКИ
  // ==========================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Заголовок "Полные настройки" (bold black 22-24)
          const Text(
            'Полные настройки',
            style: TextStyle(
              color: CupertinoColors.black,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          
          // Кнопка закрытия (×)
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 36,
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // СПИСОК НАСТРОЕК (с stagger-анимацией)
  // ==========================================================================
  Widget _buildSettingsList(WidgetRef ref) {
    // Пункты меню настроек (БЕЗ onTap, т.к. на скриншоте нет chevron)
    final menuItems = [
      _MenuItem(
        icon: CupertinoIcons.globe,
        title: 'Протокол',
      ),
      _MenuItem(
        icon: CupertinoIcons.shield_fill,
        title: 'Безопасность',
      ),
      _MenuItem(
        icon: CupertinoIcons.creditcard_fill,
        title: 'О подписке',
      ),
      _MenuItem(
        icon: CupertinoIcons.info_circle_fill,
        title: 'О приложении',
      ),
      _MenuItem(
        icon: CupertinoIcons.ellipsis_circle_fill,
        title: 'Больше',
      ),
      _MenuItem(
        icon: CupertinoIcons.server_rack,
        title: 'Серверы',
      ),
      _MenuItem(
        icon: CupertinoIcons.lock_fill,
        title: 'Шифрование',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length + 3, // +1 для "Логи", +2 для переключателей
      itemBuilder: (context, index) {
        // Базовая задержка для stagger-анимации
        final delay = index * 45;
        
        // Обычные пункты меню
        if (index < menuItems.length) {
          return _buildMenuItem(menuItems[index])
              .animate()
              .fadeIn(
                delay: delay.ms,
                duration: 300.ms,
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: delay.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              );
        }
        
        // Разделитель перед "Логи"
        if (index == menuItems.length) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 0.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CupertinoColors.systemGrey4.withOpacity(0.0),
                  CupertinoColors.systemGrey4,
                  CupertinoColors.systemGrey4.withOpacity(0.0),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: delay.ms, duration: 300.ms);
        }
        
        // Пункт "Логи"
        if (index == menuItems.length + 1) {
          return _buildMenuItem(
            _MenuItem(
              icon: CupertinoIcons.doc_text_fill,
              title: 'Логи',
            ),
          )
              .animate()
              .fadeIn(delay: delay.ms, duration: 300.ms)
              .slideX(
                begin: 0.1,
                end: 0,
                delay: delay.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              );
        }
        
        // Переключатели (Автоподключение и Темная тема)
        if (index == menuItems.length + 2) {
          return Column(
            children: [
              // Автоподключение
              _buildSwitchItem(
                icon: CupertinoIcons.arrow_2_circlepath,
                title: 'Автоподключение',
                value: ref.watch(autoConnectProvider),
                onChanged: (value) {
                  ref.read(autoConnectProvider.notifier).state = value;
                },
              ),
              
              const SizedBox(height: 8),
              
              // Темная тема
              _buildSwitchItem(
                icon: CupertinoIcons.moon_fill,
                title: 'Темная тема',
                value: ref.watch(darkThemeProvider),
                onChanged: (value) {
                  ref.read(darkThemeProvider.notifier).state = value;
                },
              ),
              
              // Отступ для нижней панели (140px)
              const SizedBox(height: 150),
            ],
          )
              .animate()
              .fadeIn(delay: delay.ms, duration: 300.ms)
              .slideX(
                begin: 0.1,
                end: 0,
                delay: delay.ms,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  // ==========================================================================
  // ОБЫЧНЫЙ ПУНКТ МЕНЮ (без chevron)
  // ==========================================================================
  Widget _buildMenuItem(_MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Иконка
          Icon(
            item.icon,
            size: 24,
            color: const Color(0xFF007AFF), // iOS blue
          ),
          
          const SizedBox(width: 14),
          
          // Текст
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ПУНКТ С ПЕРЕКЛЮЧАТЕЛЕМ
  // ==========================================================================
  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Иконка
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF007AFF),
          ),
          
          const SizedBox(width: 14),
          
          // Текст
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.4,
              ),
            ),
          ),
          
          // Переключатель (CupertinoSwitch)
          Transform.scale(
            scale: 0.85, // Чуть меньше стандартного размера
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF34C759), // iOS зелёный
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // НИЖНЯЯ ФИКСИРОВАННАЯ ПАНЕЛЬ (белые карточки + ID)
  // ==========================================================================
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        // Градиент для fade-эффекта сверху
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF2F2F7).withOpacity(0.0),
            const Color(0xFFF2F2F7).withOpacity(0.95),
            const Color(0xFFF2F2F7),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Две белые карточки (скорость и дата)
          Row(
            children: [
              // Левая карточка: СКОРОСТЬ
              Expanded(
                child: _buildBottomCard(
                  label: 'СКОРОСТЬ',
                  value: '0 мбит/с',
                  icon: CupertinoIcons.arrow_down,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Правая карточка: ДО
              Expanded(
                child: _buildBottomCard(
                  label: 'ДО',
                  value: '13.04',
                  icon: CupertinoIcons.calendar,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // ID внизу (мелкий серый текст)
          Text(
            'ID: 4829105736',
            style: TextStyle(
              color: CupertinoColors.systemGrey.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // БЕЛАЯ КАПСУЛЬНАЯ КАРТОЧКА (для нижней панели)
  // ==========================================================================
  Widget _buildBottomCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        // БЕЛЫЙ фон
        color: CupertinoColors.white,
        // Полукруглые края (капсульная форма)
        borderRadius: BorderRadius.circular(20),
        // Тень для объёма
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          // Лёгкая внутренняя подсветка (имитация через вторую тень)
          BoxShadow(
            color: CupertinoColors.white.withOpacity(0.8),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
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
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Значение (0 мбит/с / 13.04)
          Row(
            children: [
              // Иконка
              if (label == 'СКОРОСТЬ')
                Icon(
                  icon,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              if (label == 'СКОРОСТЬ') const SizedBox(width: 6),
              
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 20,
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
    // Лёгкая пульсация карточки (loop animation)
    .animate(
      onPlay: (controller) => controller.repeat(),
    )
    .scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.015, 1.015),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    )
    .then()
    .scale(
      begin: const Offset(1.015, 1.015),
      end: const Offset(1.0, 1.0),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    );
  }
}

// ============================================================================
// МОДЕЛЬ ПУНКТА МЕНЮ
// ============================================================================

class _MenuItem {
  final IconData icon;
  final String title;

  _MenuItem({
    required this.icon,
    required this.title,
  });
}
