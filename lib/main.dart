import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // ProviderScope для Riverpod state management
    const ProviderScope(
      child: VPNApp(),
    ),
  );
}

class VPNApp extends StatelessWidget {
  const VPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Arctic VPN',
      debugShowCheckedModeBanner: false,
      
      // CUPERTINO THEME (iOS-стиль)
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF007AFF), // iOS blue
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.black,
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text', // iOS системный шрифт
            fontSize: 17,
            letterSpacing: -0.4,
          ),
        ),
      ),
      
      // Главный экран
      home: const HomeScreen(),
      
      // Локализация (русский язык)
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
    );
  }
}
