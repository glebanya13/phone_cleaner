import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ambient lighting background that delivers Apple Liquid Glass atmosphere
/// with optimal GPU shader performance (no expensive per-frame CPU trig math).
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: LiquidTokens.bgDark),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top-Left Indigo Aurora Glow
          Positioned(
            top: -120,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidTokens.primary.withValues(alpha: 0.32),
                      LiquidTokens.primary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Bottom-Right Deep Purple Glow
          Positioned(
            bottom: -140,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                      const Color(0xFF6366F1).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Mid-Screen Subtle Cyan Accent
          Positioned(
            top: 260,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      LiquidTokens.accent.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),
          ),

          // Subtle overall ambient gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  LiquidTokens.bgDark.withValues(alpha: 0.4),
                  LiquidTokens.bgDark.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Primary Content
          child,
        ],
      ),
    );
  }
}
