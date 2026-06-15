import 'package:flutter/material.dart';
import '../theme.dart';

class RatingWidget extends StatelessWidget {
  final double value;
  final int? reviews;
  final double size;

  const RatingWidget({
    super.key,
    required this.value,
    this.reviews,
    this.size = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: AppColors.gold),
        const SizedBox(width: 4),
        Text(
          value.toStringAsFixed(1),
          style: AppText.manrope(fontSize: size, fontWeight: FontWeight.w700),
        ),
        if (reviews != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviews)',
            style: AppText.manrope(fontSize: size - 1, color: AppColors.faint),
          ),
        ],
      ],
    );
  }
}
