import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF2F2F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ArcticVPN());
}

class ArcticVPN extends StatelessWidget {
  const ArcticVPN({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arctic VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      ),
      home: const OnboardingScreen(),
    );
  }
}
