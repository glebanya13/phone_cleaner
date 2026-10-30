import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Refined Liquid Glass surface with ambient specular border and restrained blur.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? tintColor;
  final VoidCallback? onTap;
  final double blur;
  final Border? border;
  final bool hasGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LiquidTokens.space16),
    this.radius = LiquidTokens.radiusLg,
    this.tintColor,
    this.onTap,
    this.blur = 16.0,
    this.border,
    this.hasGlow = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _pressController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _pressController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _pressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTint = widget.tintColor ?? LiquidTokens.glassSurface;

    Widget cardBody = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: effectiveTint,
            borderRadius: BorderRadius.circular(widget.radius),
            border:
                widget.border ??
                Border.all(color: LiquidTokens.glassBorder, width: 1.0),
            boxShadow: widget.hasGlow
                ? LiquidTokens.ambientGlow
                : LiquidTokens.glassDropShadow,
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(scale: _scaleAnimation, child: cardBody),
      );
    }

    return cardBody;
  }
}

/// A specialized Liquid Glass pill badge for metadata, statuses, and tags.
class LiquidBadge extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color? color;
  final bool isProminent;

  const LiquidBadge({
    super.key,
    this.icon,
    required this.label,
    this.color,
    this.isProminent = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? LiquidTokens.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isProminent
            ? accentColor.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(LiquidTokens.radiusFull),
        border: Border.all(
          color: isProminent
              ? accentColor.withValues(alpha: 0.4)
              : LiquidTokens.glassBorderSubtle,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isProminent ? accentColor : LiquidTokens.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary action button with Liquid Glass styling and smooth interaction states.
class LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final bool isSecondary;

  const LiquidButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isSecondary = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final primaryColor = widget.isDestructive
        ? LiquidTokens.danger
        : (widget.isSecondary
              ? LiquidTokens.glassSurfaceHighlight
              : LiquidTokens.primary);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: isEnabled
            ? (_) {
                _controller.forward();
                HapticFeedback.lightImpact();
              }
            : null,
        onTapUp: isEnabled
            ? (_) {
                _controller.reverse();
              }
            : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: widget.isSecondary
                ? Colors.white.withValues(alpha: 0.08)
                : (isEnabled
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(LiquidTokens.radiusMd),
            border: Border.all(
              color: widget.isSecondary
                  ? LiquidTokens.glassBorder
                  : Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: (!widget.isSecondary && isEnabled)
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
