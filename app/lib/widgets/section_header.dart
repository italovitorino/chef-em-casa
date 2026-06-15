import 'package:flutter/material.dart';
import '../theme.dart';

class SectionHeader extends StatelessWidget {
  final String? kicker;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    this.kicker,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kicker != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    kicker!,
                    style: AppText.spaceMono(
                      fontSize: 10.5,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              Text(
                title,
                style: AppText.cormorant(fontSize: 27),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  action!,
                  style: AppText.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_right, color: AppColors.muted, size: 15),
              ],
            ),
          ),
      ],
    );
  }
}
