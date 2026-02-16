import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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
        child: Column(
          children: [
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
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showSettings(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.more_vert, color: Color(0xFF007AFF)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (!_isConnected)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: const Text(
                  'Чтобы включить ВПН нажмите на кнопку',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Color(0xFF3C3C43)),
                ),
              ),
            if (!_isConnected) const SizedBox(height: 40),
            _buildConnectionButton(),
            const SizedBox(height: 24),
            Text(
              _formatTime(_seconds),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard('СКОРОСТЬ', '$_speed мбит/с'),
                  const SizedBox(width: 12),
                  _buildStatCard('ДО', '13.04'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ID: 4829105736',
              style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _toggleConnection,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: _isConnected
                  ? const Color(0xFF34C759).withOpacity(0.3)
                  : const Color(0xFF007AFF).withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 20,
              offset: const Offset(-10, -10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(10, 10),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: _isConnecting
                    ? const CircularProgressIndicator(color: Color(0xFF007AFF))
                    : _isConnected
                        ? const Icon(Icons.check_rounded, size: 80, color: Color(0xFF34C759))
                        : const Text('❄️', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SettingsScreen(),
    );
  }
}
