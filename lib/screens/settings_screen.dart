import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// ПРОВАЙДЕРЫ STATE
// ============================================================================

final autoConnectProvider = StateProvider<bool>((ref) => false);
final darkThemeProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// ЦВЕТА (светлая тема)
// ============================================================================

const kBackgroundColor = Color(0xFFF2F2F7);
const kCardColor = Color(0xFFFFFFFF);
const kAccentColor = Color(0xFF007AFF);
const kTextColor = Color(0xFF000000);
const kSecondaryText = Color(0xFF8E8E93);

// ============================================================================
// МОДАЛЬНОЕ ОКНО НАСТРОЕК
// ============================================================================

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.3),
      builder: (context) => const SettingsScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Blur-фон (glassmorphism)
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

        // Сам модальный контейнер с анимацией появления
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              width: screenWidth - 32,
              height: screenHeight * 0.78,
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildHeader(context),
                        Expanded(child: _buildSettingsList(ref)),
                      ],
                    ),
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
                // Главная анимация модалки (как в chill-видео)
                .animate()
                .slideY(begin: 0.20, end: 0.0, duration: 600.ms, curve: Curves.easeOutCubicEmphasized)
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.0, 1.0), duration: 600.ms),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ЗАГОЛОВОК
  // ==========================================================================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Полные настройки',
            style: TextStyle(
              color: kTextColor,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 36,
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.xmark,
                color: kSecondaryText,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  // ==========================================================================
  // СПИСОК НАСТРОЕК (stagger + slide + fade)
  // ==========================================================================
  Widget _buildSettingsList(WidgetRef ref) {
    final menuItems = [
      _MenuItem(icon: CupertinoIcons.globe, title: 'Протокол'),
      _MenuItem(icon: CupertinoIcons.shield_fill, title: 'Безопасность'),
      _MenuItem(icon: CupertinoIcons.creditcard_fill, title: 'О подписке'),
      _MenuItem(icon: CupertinoIcons.info_circle_fill, title: 'О приложении'),
      _MenuItem(icon: CupertinoIcons.ellipsis_circle_fill, title: 'Больше'),
      _MenuItem(icon: CupertinoIcons.cloud_server, title: 'Серверы'),
      _MenuItem(icon: CupertinoIcons.lock_fill, title: 'Шифрование'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length + 3,
      itemBuilder: (context, index) {
        final delay = index * 60; // stagger-эффект (каждый следующий пункт позже)

        if (index < menuItems.length) {
          return _buildMenuItem(menuItems[index])
              .animate()
              .fadeIn(delay: delay.ms, duration: 400.ms)
              .slideX(begin: 0.15, end: 0.0, delay: delay.ms, duration: 450.ms, curve: Curves.easeOutCubic);
        }

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
          ).animate().fadeIn(delay: delay.ms, duration: 400.ms);
        }

        if (index == menuItems.length + 1) {
          return _buildMenuItem(
            _MenuItem(icon: CupertinoIcons.doc_text_fill, title: 'Логи'),
          ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideX(begin: 0.15, end: 0.0, delay: delay.ms);
        }

        // Переключатели + отступ
        return Column(
          children: [
            _buildSwitchItem(
              icon: CupertinoIcons.arrow_2_circlepath,
              title: 'Автоподключение',
              value: ref.watch(autoConnectProvider),
              onChanged: (v) => ref.read(autoConnectProvider.notifier).state = v,
            ).animate().fadeIn(delay: delay.ms, duration: 400.ms).slideX(begin: 0.15, end: 0.0),
            const SizedBox(height: 8),
            _buildSwitchItem(
              icon: CupertinoIcons.moon_fill,
              title: 'Темная тема',
              value: ref.watch(darkThemeProvider),
              onChanged: (v) => ref.read(darkThemeProvider.notifier).state = v,
            ).animate().fadeIn(delay: delay.ms + 60, duration: 400.ms).slideX(begin: 0.15, end: 0.0),
            const SizedBox(height: 150),
          ],
        );
      },
    );
  }

  // ==========================================================================
  // ПУНКТ МЕНЮ
  // ==========================================================================
  Widget _buildMenuItem(_MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
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
          Icon(item.icon, size: 24, color: kAccentColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: kTextColor,
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
        color: kCardColor,
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
          Icon(icon, size: 24, color: kAccentColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: kTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF34C759),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // НИЖНЯЯ ПАНЕЛЬ (с пульсацией)
  // ==========================================================================
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kBackgroundColor.withOpacity(0.0),
            kBackgroundColor.withOpacity(0.95),
            kBackgroundColor,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildBottomCard(
                  label: 'СКОРОСТЬ',
                  value: '0 мбит/с',
                  icon: CupertinoIcons.arrow_down,
                ),
              ),
              const SizedBox(width: 12),
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
          Text(
            'ID: 4829105736',
            style: TextStyle(
              color: kSecondaryText.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: kSecondaryText.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (label == 'СКОРОСТЬ')
                Icon(icon, size: 16, color: kSecondaryText),
              if (label == 'СКОРОСТЬ') const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: kTextColor,
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
        // Пульсация (как в расслабляющем видео)
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.015, 1.015),
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;

  _MenuItem({required this.icon, required this.title});
}