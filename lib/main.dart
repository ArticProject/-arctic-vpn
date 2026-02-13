import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ArcticVpnApp());
}

class ArcticVpnApp extends StatelessWidget {
  const ArcticVpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arctic VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isConnected = false;
  int sessionSeconds = 0;
  Timer? _timer;

  final String expiryDate = "19.03.2026";
  final double usedGB = 31.3;
  final double totalGB = 100.0;

  late String userId;

  @override
  void initState() {
    super.initState();
    userId =
        (Random().nextInt(90000000000) + 10000000000).toString();
  }

  void startTimer() {
    _timer?.cancel();
    sessionSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        sessionSeconds++;
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
    sessionSeconds = 0;
  }

  // ✅ ИСПРАВЛЕННЫЙ МЕТОД
  String getSessionTime() {
    int minutes = sessionSeconds ~/ 60;
    int seconds = sessionSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A1421),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Arctic VPN',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.settings, size: 24),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.send, size: 24),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Text(
                        'Чтобы выключить\nVPN нажмите на кнопку',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isConnected = !isConnected;
                        });

                        if (isConnected) {
                          startTimer();
                        } else {
                          stopTimer();
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isConnected
                                ? [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF1B5E20)
                                  ]
                                : [
                                    const Color(0xFF40C4FF),
                                    const Color(0xFF01579B)
                                  ],
                          ),
                          boxShadow: isConnected
                              ? [
                                  BoxShadow(
                                    color: Colors.greenAccent
                                        .withOpacity(0.5),
                                    blurRadius: 40,
                                    spreadRadius: 20,
                                  )
                                ]
                              : [],
                        ),
                        child: const Icon(
                          Icons.ac_unit_rounded,
                          size: 160,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    Text(
                      isConnected
                          ? 'Connected ❄️'
                          : 'Disconnected',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isConnected
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Подписка до $expiryDate',
                      style: const TextStyle(
                          fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),

                    if (isConnected)
                      Text(
                        'Сеанс: ${getSessionTime()}',
                        style: const TextStyle(
                            fontSize: 20, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCard(
                          title: 'Скорость',
                          value: '0 Мбит/с',
                          icon: Icons.speed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCard(
                          title: 'Осталось',
                          value:
                              '${(totalGB - usedGB).toStringAsFixed(1)} ГБ / $totalGB ГБ',
                          icon: Icons.data_usage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ID: $userId',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
