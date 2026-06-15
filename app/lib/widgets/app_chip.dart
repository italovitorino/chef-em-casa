import 'package:flutter/material.dart';
import '../theme.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.cream : AppColors.line2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: active ? const Color(0xFF231A0F) : AppColors.gold),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: AppText.manrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: active ? const Color(0xFF231A0F) : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
