import 'package:flutter/material.dart';
import '../theme.dart';

class AppPlaceholder extends StatelessWidget {
  final String? label;
  final int hue;
  final double height;
  final double radius;
  final IconData icon;
  final bool showLabel;

  const AppPlaceholder({
    super.key,
    this.label,
    this.hue = 24,
    required this.height,
    this.radius = 18,
    this.icon = Icons.restaurant,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _PlaceholderPainter(hue: hue)),
            // center mark
            Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line2),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0x80F4EFE6),
                ),
              ),
            ),
            // label
            if (showLabel && label != null && label!.isNotEmpty)
              Positioned(
                left: 9,
                bottom: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x52000000),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    label!,
                    style: AppText.spaceMono(
                      fontSize: 9.5,
                      color: const Color(0x8CF4EFE6),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPainter extends CustomPainter {
  final int hue;
  _PlaceholderPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // base gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2A1F15), Color(0xFF1C150E)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // hue tint — top-left radial
    final normalizedHue = hue.toDouble().clamp(0.0, 360.0);
    final tintColor = HSLColor.fromAHSL(1.0, normalizedHue, 0.45, 0.22).toColor();
    final radPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.7),
        radius: 1.4,
        colors: [
          tintColor.withAlpha(179),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55],
      ).createShader(rect);
    canvas.drawRect(rect, radPaint);

    // secondary tint — bottom-right
    final tint2Color = HSLColor.fromAHSL(1.0, (normalizedHue + 12) % 360, 0.35, 0.18).toColor();
    final rad2Paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.2, 1.2),
        radius: 1.3,
        colors: [
          tint2Color.withAlpha(153),
          Colors.transparent,
        ],
        stops: const [0.0, 0.60],
      ).createShader(rect);
    canvas.drawRect(rect, rad2Paint);

    // diagonal hairlines
    final linePaint = Paint()
      ..color = const Color(0x0DF4EFE6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const step = 13.0;
    final diag = size.height;
    for (double x = -diag; x < size.width + diag; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + diag, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PlaceholderPainter old) => old.hue != hue;
}
