import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'Добро пожаловать',
      description: 'Arctic VPN — ваша безопасность в сети',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A3A52), Color(0xFF000000)],
      ),
    ),
    _OnboardingData(
      title: 'Мгновенное подключение',
      description: 'Одно нажатие — и вы защищены',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D3B2E), Color(0xFF000000)],
      ),
    ),
    _OnboardingData(
      title: 'Скорость до 13 Гбит/с',
      description: 'Максимальная производительность без ограничений',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E4D3D), Color(0xFF000000)],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // PAGE VIEW
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index);
            },
          ),

          // ИНДИКАТОРЫ
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white
                        .withOpacity(_currentPage == index ? 1.0 : 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    );
              }),
            ),
          ),

          // КНОПКА "НАЧАТЬ"
          if (_currentPage == _pages.length - 1)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: const Color(0xFF00BFA5),
                borderRadius: BorderRadius.circular(28),
                onPressed: _completeOnboarding,
                child: const Text(
                  'Начать',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data, int index) {
    return Container(
      decoration: BoxDecoration(gradient: data.gradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // СНЕЖИНКА
            const Icon(
              CupertinoIcons.snow,
              size: 120,
              color: Color(0xFF64B5F6),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(
                  begin: 0,
                  end: 1,
                  duration: 3000.ms,
                  curve: Curves.linear,
                )
                .then()
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 60),

            // ЗАГОЛОВОК
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                fontFamily: '.SF Pro Display',
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 20),

            // ОПИСАНИЕ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  fontFamily: '.SF Pro Text',
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final Gradient gradient;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.gradient,
  });
}
