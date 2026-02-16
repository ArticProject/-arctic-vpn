class OnboardingModel {
  final String title;
  final String subtitle;
  final List<FeatureItem> features;
  final bool isWelcome;

  OnboardingModel({
    required this.title,
    this.subtitle = '',
    required this.features,
    this.isWelcome = false,
  });
}

class FeatureItem {
  final String icon;
  final String title;
  final String description;
  final Color color;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

// iOS Colors for icons
import 'package:flutter/material.dart';

final List<OnboardingModel> onboardingPages = [
  // Page 1: Welcome
  OnboardingModel(
    title: 'Добро пожаловать\nв Arctic VPN',
    subtitle: 'Безопасный и быстрый доступ к интернету',
    isWelcome: true,
    features: [
      FeatureItem(
        icon: '❄️',
        title: 'Arctic VPN',
        description: 'Защитите свое соединение с помощью передовых технологий шифрования',
        color: const Color(0xFF007AFF),
      ),
    ],
  ),
  
  // Page 2: Features
  OnboardingModel(
    title: 'Вам доступно\n10 ГБ интернета',
    subtitle: 'Пробный период для новых пользователей',
    features: [
      FeatureItem(
        icon: '📊',
        title: '10 ГБ трафика',
        description: 'Бесплатно используйте 10 ГБ интернета в высоком качестве',
        color: const Color(0xFF34C759),
      ),
      FeatureItem(
        icon: '⚡',
        title: 'Высокая скорость',
        description: 'Серверы по всему миру обеспечивают стабильное соединение',
        color: const Color(0xFFFF9500),
      ),
      FeatureItem(
        icon: '🛡️',
        title: 'Безопасность',
        description: 'Военный уровень шифрования AES-256',
        color: const Color(0xFF5856D6),
      ),
    ],
  ),
  
  // Page 3: Start
  OnboardingModel(
    title: 'Начните\nпрямо сейчас',
    subtitle: 'Один кнопка для защиты ваших данных',
    features: [
      FeatureItem(
        icon: '🚀',
        title: 'Быстрый старт',
        description: 'Нажмите кнопку подключения и получите доступ к безграничному интернету',
        color: const Color(0xFF007AFF),
      ),
    ],
  ),
];
