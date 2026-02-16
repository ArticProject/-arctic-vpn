import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: const Color(0xFF007AFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow && trailing == null)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: Color(0xFFC7C7CC),
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF007AFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF000000),
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }
}
