import 'package:flutter/material.dart';

/// Animated circular ATS score indicator with color-coded ring and score label.
class ScoreCircle extends StatelessWidget {
  final int score;
  final double size;

  const ScoreCircle({
    super.key,
    required this.score,
    this.size = 160,
  });

  Color get _scoreColor {
    if (score >= 75) return const Color(0xFF00C896); // green
    if (score >= 50) return const Color(0xFFFFB347); // orange
    return const Color(0xFFFF6B6B);                  // red
  }

  String get _scoreLabel {
    if (score >= 75) return 'Excellent';
    if (score >= 55) return 'Good';
    if (score >= 35) return 'Fair';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: score / 100),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _scoreColor.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFCBD5E1).withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation(_scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Inner content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(value * 100).round()}',
                        style: TextStyle(
                          fontSize: size * 0.28,
                          fontWeight: FontWeight.w800,
                          color: _scoreColor,
                          height: 1,
                        ),
                      ),
                      Text(
                        'ATS Score',
                        style: TextStyle(
                          fontSize: size * 0.1,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Score label badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _scoreColor.withOpacity(0.4)),
              ),
              child: Text(
                _scoreLabel,
                style: TextStyle(
                  color: _scoreColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
