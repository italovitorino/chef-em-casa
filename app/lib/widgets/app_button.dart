import 'package:flutter/material.dart';
import '../theme.dart';

enum AppButtonVariant { primary, gold, ghost, soft }
enum AppButtonSize { lg, md, sm }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.icon,
    this.expand = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final height = switch (widget.size) {
      AppButtonSize.lg => 56.0,
      AppButtonSize.md => 48.0,
      AppButtonSize.sm => 40.0,
    };
    final fontSize = switch (widget.size) {
      AppButtonSize.lg => 16.5,
      AppButtonSize.md => 15.0,
      AppButtonSize.sm => 13.5,
    };

    final (bg, fg, shadow, border) = switch (widget.variant) {
      AppButtonVariant.primary => (
          AppColors.terra,
          Colors.white,
          const Color(0xB2C8462A),
          null,
        ),
      AppButtonVariant.gold => (
          AppColors.gold,
          const Color(0xFF231A0F),
          const Color(0x99E0A458),
          null,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          AppColors.cream,
          null,
          AppColors.line2,
        ),
      AppButtonVariant.soft => (
          AppColors.surfaceHi,
          AppColors.cream,
          null,
          AppColors.line,
        ),
    };

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: fg, size: widget.size == AppButtonSize.lg ? 20 : 18),
          const SizedBox(width: 9),
        ],
        Text(widget.label, style: AppText.manrope(fontSize: fontSize, fontWeight: FontWeight.w700, color: fg)),
      ],
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: disabled ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: height,
            width: widget.expand ? double.infinity : null,
            padding: widget.expand ? null : const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: border != null ? Border.all(color: border, width: 1.5) : null,
              boxShadow: shadow != null && !disabled
                  ? [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                        spreadRadius: -8,
                      ),
                    ]
                  : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
