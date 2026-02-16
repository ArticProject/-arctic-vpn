import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/connection_button.dart';
import '../widgets/stat_card.dart';
import '../widgets/glass_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _timer;
  int _seconds = 0;
  String _speed = '0';
  String _ping = '13.04';

  void _toggleConnection() {
    if (_isConnected) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
        _timer?.cancel();
        _seconds = 0;
      });
    } else {
      setState(() => _isConnecting = true);
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _isConnected = true;
          });
          _startTimer();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Simulate speed changes
        if (_seconds % 3 == 0) {
          _speed = (double.parse(_speed) + 0.5).toStringAsFixed(1);
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ARCTIC VPN',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          color: Color(0xFF000000),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showMenu(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.ellipsis,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Info card
                if (!_isConnected) ...[
                  GlassCard(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      'Чтобы включить ВПН нажмите на кнопку',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF3C3C43),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],

                // Connection button
                ConnectionButton(
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                  onTap: _toggleConnection,
                ),

                const SizedBox(height: 24),

                // Timer
                Text(
                  _formatTime(_seconds),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                    letterSpacing: -0.5,
                  ),
                ),

                const Spacer(),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      StatCard(
                        title: 'СКОРОСТЬ',
                        value: '$_speed мбит/с',
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        title: 'ПИНГ',
                        value: '$_ping',
                        subtitle: 'мс',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ID
                Text(
                  'ID: 4829105736',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsScreen(),
    );
  }
}
