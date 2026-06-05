import 'package:flutter/material.dart';
import '../theme.dart';

class AppTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icon, size: 19, color: AppColors.gold),
              const SizedBox(width: 11),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: AppText.manrope(fontSize: 15.5),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  cursorColor: AppColors.terra,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }
}
