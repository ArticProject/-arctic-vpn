import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart' as inset;

void main() {
  runApp(const ArcticApp());
}

class ArcticApp extends StatelessWidget {
  const ArcticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
      ),
      home: const ArcticHome(),
    );
  }
}

class ArcticHome extends StatefulWidget {
  const ArcticHome({super.key});

  @override
  State<ArcticHome> createState() => _ArcticHomeState();
}

class _ArcticHomeState extends State<ArcticHome> {
  bool isConnected = false;
  int seconds = 0;
  Timer? timer;
  double fakeSpeed = 0;
  final Random random = Random();

  void toggleVPN() {
    setState(() {
      isConnected = !isConnected;
    });

    if (isConnected) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          seconds++;
          fakeSpeed = 40 + random.nextDouble() * 80;
        });
      });
    } else {
      timer?.cancel();
      setState(() {
        seconds = 0;
        fakeSpeed = 0;
      });
    }
  }

  String formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 16),

            const Text(
              "ARCTIC VPN",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isConnected
                    ? "VPN подключён"
                    : "Чтобы включить VPN нажмите кнопку ниже",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 50),

            /// MAIN BUTTON
            GestureDetector(
              onTap: toggleVPN,
              child: _NeumorphicButton(isConnected: isConnected),
            ),

            const SizedBox(height: 30),

            Text(
              formatTime(seconds),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: "СКОРОСТЬ",
                      value: "${fakeSpeed.toStringAsFixed(1)} мбит/с",
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: _InfoCard(
                      title: "ДО",
                      value: "13.04",
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "ID: 4829105736",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeumorphicButton extends StatelessWidget {
  final bool isConnected;
  const _NeumorphicButton({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F2F7);

    return inset.Container(
      width: 190,
      height: 190,
      decoration: inset.BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          inset.BoxShadow(
            blurRadius: 30,
            offset: const Offset(15, 15),
            color: Colors.grey.shade400,
          ),
          const inset.BoxShadow(
            blurRadius: 30,
            offset: Offset(-15, -15),
            color: Colors.white,
          ),
        ],
      ),
      child: Center(
        child: inset.Container(
          width: 130,
          height: 130,
          decoration: inset.BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              inset.BoxShadow(
                inset: true,
                blurRadius: 20,
                offset: const Offset(5, 5),
                color: Colors.grey.shade300,
              ),
              inset.BoxShadow(
                inset: true,
                blurRadius: 20,
                offset: const Offset(-5, -5),
                color: Colors.white,
              ),
              inset.BoxShadow(
                blurRadius: isConnected ? 25 : 0,
                color: isConnected
                    ? Colors.blue.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ],
          ),
          child: Icon(
            Icons.ac_unit,
            size: 60,
            color: isConnected
                ? Colors.blueAccent
                : Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F2F7);

    return inset.Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: inset.BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          inset.BoxShadow(
            blurRadius: 20,
            offset: const Offset(10, 10),
            color: Colors.grey.shade400,
          ),
          const inset.BoxShadow(
            blurRadius: 20,
            offset: Offset(-10, -10),
            color: Colors.white,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
