import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> 
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _finishOnboarding,
                  child: Text(
                    'Пропустить',
                    style: TextStyle(
                      color: const Color(0xFF007AFF).withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  return _buildPage(onboardingPages[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
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

                  // Continue button
                  GlassButton(
                    text: _currentPage == onboardingPages.length - 1 
                        ? 'Начать' 
                        : 'Продолжить',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingModel page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.isWelcome) ...[
            // Snowflake icon for welcome
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Text(
                  '❄️',
                  style: TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          if (page.subtitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF8E8E93),
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Features list
          ...page.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: feature.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            feature.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
