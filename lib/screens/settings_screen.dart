import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoConnect = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Полные настройки',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 16,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings list
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      SettingsItem(
                        icon: CupertinoIcons.globe,
                        title: 'Протокол',
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: CupertinoIcons.shield_fill,
                        title: 'Безопасность',
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: CupertinoIcons.creditcard_fill,
                        title: 'О подписке',
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: CupertinoIcons.info_circle_fill,
                        title: 'О приложении',
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: CupertinoIcons.ellipsis_circle_fill,
                        title: 'Больше',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      SettingsItem(
                        icon: CupertinoIcons.square_stack_3d_up_fill,
                        title: 'Серверы',
                        onTap: () {},
                      ),
                      SettingsItem(
                        icon: CupertinoIcons.lock_fill,
                        title: 'Шифрование',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      SettingsItem(
                        icon: CupertinoIcons.doc_text_fill,
                        title: 'Логи',
                        onTap: () {},
                      ),
                      SettingsToggle(
                        icon: CupertinoIcons.arrow_2_circlepath,
                        title: 'Автоподключение',
                        value: _autoConnect,
                        onChanged: (v) => setState(() => _autoConnect = v),
                      ),
                      SettingsToggle(
                        icon: CupertinoIcons.moon_fill,
                        title: 'Темная тема',
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
