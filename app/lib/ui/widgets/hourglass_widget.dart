import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

/// Custom hourglass widget with animations for grain movement
class HourglassWidget extends StatefulWidget {
  final int potentialGrains; // White grains in top chamber
  final double heritageGrains; // Golden grains in bottom chamber
  final bool isAnimating; // Trigger descent animation
  final VoidCallback? onAnimationComplete;

  const HourglassWidget({
    super.key,
    required this.potentialGrains,
    required this.heritageGrains,
    this.isAnimating = false,
    this.onAnimationComplete,
  });

  @override
  State<HourglassWidget> createState() => _HourglassWidgetState();
}

class _HourglassWidgetState extends State<HourglassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    if (widget.isAnimating) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(HourglassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.forward(from: 0).then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kHourglassAspectRatio,
      child: CustomPaint(
        painter: HourglassPainter(
          potentialGrains: widget.potentialGrains,
          heritageGrains: widget.heritageGrains,
          animationProgress: _controller.value,
        ),
      ),
    );
  }
}

class HourglassPainter extends CustomPainter {
  final int potentialGrains;
  final double heritageGrains;
  final double animationProgress;

  HourglassPainter({
    required this.potentialGrains,
    required this.heritageGrains,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final hourglassWidth = size.width * 0.6;
    final hourglassHeight = size.height * 0.9;
    final chamberHeight = hourglassHeight * 0.4;

    // Draw hourglass frame
    final framePaint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final framePath = Path();

    // Top chamber
    framePath.moveTo(center.dx - hourglassWidth / 2, center.dy - hourglassHeight / 2);
    framePath.lineTo(center.dx + hourglassWidth / 2, center.dy - hourglassHeight / 2);
    framePath.lineTo(center.dx + hourglassWidth / 4, center.dy);

    // Bottom chamber
    framePath.lineTo(center.dx + hourglassWidth / 2, center.dy + hourglassHeight / 2);
    framePath.lineTo(center.dx - hourglassWidth / 2, center.dy + hourglassHeight / 2);
    framePath.lineTo(center.dx - hourglassWidth / 4, center.dy);
    framePath.close();

    canvas.drawPath(framePath, framePaint);

    // Draw potential grains (white) in top chamber
    final whitePaint = Paint()..color = AppColors.whiteGrain;
    final topChamberY = center.dy - chamberHeight / 2;

    for (int i = 0; i < potentialGrains; i++) {
      final x = center.dx + (i % 5 - 2) * 8;
      final y = topChamberY + (i ~/ 5) * 8;
      canvas.drawCircle(Offset(x, y), 3, whitePaint);
    }

    // Draw heritage grains (golden) in bottom chamber
    final goldPaint = Paint()..color = AppColors.goldenGrain;
    final bottomChamberY = center.dy + chamberHeight / 2;
    final grainsToShow = heritageGrains.toInt();

    for (int i = 0; i < math.min(grainsToShow, 100); i++) {
      final x = center.dx + (i % 5 - 2) * 8;
      final y = bottomChamberY - (i ~/ 5) * 8;
      canvas.drawCircle(Offset(x, y), 3, goldPaint);
    }

    // Draw falling grains animation
    if (animationProgress > 0 && animationProgress < 1) {
      final fallingPaint = Paint()..color = AppColors.goldenGrain;
      final fallingY = topChamberY + (bottomChamberY - topChamberY) * animationProgress;

      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(center.dx + (i - 1) * 6, fallingY),
          2,
          fallingPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(HourglassPainter oldDelegate) {
    return oldDelegate.potentialGrains != potentialGrains ||
        oldDelegate.heritageGrains != heritageGrains ||
        oldDelegate.animationProgress != animationProgress;
  }
}

/// Grain counter display widget
class GrainCounter extends StatelessWidget {
  final double grains;
  final String label;
  final Color color;

  const GrainCounter({
    super.key,
    required this.grains,
    required this.label,
    this.color = AppColors.goldenGrain,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          grains.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
