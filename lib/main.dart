import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArcticVPNApp());
}

class ArcticVPNApp extends StatefulWidget {
  const ArcticVPNApp({super.key});

  @override
  State<ArcticVPNApp> createState() => _ArcticVPNAppState();
}

class _ArcticVPNAppState extends State<ArcticVPNApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(
        isDark: isDark,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  int seconds = 0;
  double speed = 0;
  Timer? timer;
  Timer? speedTimer;

  void toggleVPN() {
    setState(() {
      isConnected = !isConnected;
    });

    if (isConnected) {
      startTimer();
      startSpeed();
    } else {
      stopTimer();
      stopSpeed();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    seconds = 0;
  }

  void startSpeed() {
    speedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        speed = Random().nextDouble() * 50;
      });
    });
  }

  void stopSpeed() {
    speedTimer?.cancel();
    speed = 0;
  }

  String get formattedTime {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    timer?.cancel();
    speedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final cardColor =
        widget.isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ARCTIC VPN",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: textColor,
                    onPressed: widget.toggleTheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Hint Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isConnected
                    ? "Чтобы выключить VPN нажмите на кнопку"
                    : "Чтобы включить VPN нажмите на кнопку",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Main Button
            GestureDetector(
              onTap: toggleVPN,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? Colors.blue
                      : (widget.isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: isConnected
                          ? Colors.blue.withOpacity(0.6)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.ac_unit,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Timer
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 26,
                color: textColor,
              ),
            ),

            const SizedBox(height: 40),

            // Speed Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "СКОРОСТЬ",
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${speed.toStringAsFixed(1)} мбит/с",
                            style: TextStyle(
                              fontSize: 22,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "ДО",
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "13.04",
                            style: TextStyle(
                              fontSize: 22,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "ID: 4829105736",
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
