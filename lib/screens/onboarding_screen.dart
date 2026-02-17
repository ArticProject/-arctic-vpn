import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/glass_button.dart';
import 'package:arctic_vpn/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Добро пожаловать\nв Arctic VPN',
      'subtitle': 'Безопасный и быстрый доступ к интернету',
      'icon': '❄️',
      'features': [
        {
          'icon': '🔒',
          'title': 'Защита данных',
          'desc': 'Военный уровень шифрования AES-256',
          'color': Color(0xFF007AFF),
        },
      ],
    },
    {
      'title': 'Вам доступно\n10 ГБ интернета',
      'subtitle': 'Пробный период для новых пользователей',
      'icon': '🎁',
      'features': [
        {
          'icon': '📊',
          'title': '10 ГБ трафика',
          'desc': 'Бесплатно используйте высокоскоростной интернет',
          'color': Color(0xFF34C759),
        },
        {
          'icon': '⚡',
          'title': 'Высокая скорость',
          'desc': 'Серверы по всему миру',
          'color': Color(0xFFFF9500),
        },
        {
          'icon': '🛡️',
          'title': 'Безопасность',
          'desc': 'Полная анонимность в сети',
          'color': Color(0xFF5856D6),
        },
      ],
    },
    {
      'title': 'Начните\nпрямо сейчас',
      'subtitle': 'Одна кнопка для защиты ваших данных',
      'icon': '🚀',
      'features': [
        {
          'icon': '👆',
          'title': 'Быстрый старт',
          'desc': 'Нажмите кнопку и получите доступ к интернету',
          'color': Color(0xFF007AFF),
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => _finish(),
                  child: const Text(
                    'Пропустить',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF007AFF)
                              : const Color(0xFFD1D1D6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassButton(
                    text: _currentPage == _pages.length - 1 ? 'Начать' : 'Продолжить',
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    final features = page['features'] as List;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                page['icon'],
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page['subtitle'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 40),
          ...features.map((f) => _buildFeatureCard(f)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (f['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(f['icon'], style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['title'],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  f['desc'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
