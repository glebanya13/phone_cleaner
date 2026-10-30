import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/scan_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import 'clean_screen.dart';
import 'duplicates_screen.dart';
import 'unused_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.onSelectTab});

  void _navigateToTab(
    BuildContext context,
    int tabIndex,
    Widget fallbackScreen,
  ) {
    if (onSelectTab != null) {
      onSelectTab!(tabIndex);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => fallbackScreen),
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ГБ';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} МБ';
  }

  @override
  Widget build(BuildContext context) {
    final used = ScanService.usedStorage;
    final total = ScanService.totalStorage;
    final free = total - used;
    final usedPct = (used / total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: LiquidTokens.space16,
            vertical: LiquidTokens.space12,
          ),
          children: [
            // Header Bar
            _buildHeader(context),
            const SizedBox(height: LiquidTokens.space20),

            // Hero Storage Visualizer
            _buildHeroStorage(
              context,
              used: used,
              total: total,
              free: free,
              usedPct: usedPct,
            ),
            const SizedBox(height: LiquidTokens.space20),

            // Hero Quick Action Banner
            _buildQuickCleanHero(context),
            const SizedBox(height: LiquidTokens.space24),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Возможности очистки',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const LiquidBadge(
                  label: 'Анализ готов',
                  color: LiquidTokens.accent,
                ),
              ],
            ),
            const SizedBox(height: LiquidTokens.space12),

            // Category Cleaning Opportunities
            _buildCategoryTile(
              context: context,
              icon: LucideIcons.trash2,
              iconColor: LiquidTokens.primaryLight,
              title: 'Кэш и мусор',
              subtitle: 'Временные файлы, логи и превью',
              badgeLabel: 'Рекомендуется',
              isBadgeProminent: true,
              onTap: () => _navigateToTab(context, 1, const CleanScreen()),
            ),
            const SizedBox(height: LiquidTokens.space12),

            _buildCategoryTile(
              context: context,
              icon: LucideIcons.image,
              iconColor: const Color(0xFFC084FC),
              title: 'Дубликаты фото',
              subtitle: 'Идентичные снимки из галереи',
              badgeLabel: 'Галерея',
              onTap: () => _navigateToTab(context, 2, const DuplicatesScreen()),
            ),
            const SizedBox(height: LiquidTokens.space12),

            _buildCategoryTile(
              context: context,
              icon: LucideIcons.layers,
              iconColor: LiquidTokens.accent,
              title: 'Память программ',
              subtitle: 'Кэш и распределение ресурсов',
              badgeLabel: 'Система',
              onTap: () => _navigateToTab(context, 3, const UnusedScreen()),
            ),
            const SizedBox(height: LiquidTokens.space20),

            // Safety & Integrity Advisory Card
            _buildSafetyAdvisory(context),

            // Safe bottom padding for floating navigation bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [LiquidTokens.primary, LiquidTokens.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LiquidTokens.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: LiquidTokens.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Cleaner',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Память и оптимизация',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const LiquidBadge(
          icon: Icon(
            LucideIcons.shieldCheck,
            size: 14,
            color: LiquidTokens.success,
          ),
          label: 'Безопасно',
          color: LiquidTokens.success,
        ),
      ],
    );
  }

  Widget _buildHeroStorage(
    BuildContext context, {
    required int used,
    required int total,
    required int free,
    required double usedPct,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(LiquidTokens.space20),
      hasGlow: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Хранилище устройства',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: LiquidTokens.textSecondary,
                ),
              ),
              const LiquidBadge(
                label: 'Оценка памяти',
                color: LiquidTokens.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: LiquidTokens.space20),

          // Circular Storage Gauge with ambient center
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(170, 170),
                  painter: _StorageArcPainter(
                    percent: usedPct,
                    primaryColor: LiquidTokens.primary,
                    accentColor: LiquidTokens.accent,
                    trackColor: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(usedPct * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Занято',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LiquidTokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: LiquidTokens.space24),

          // Storage Metric Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(LiquidTokens.radiusMd),
              border: Border.all(
                color: LiquidTokens.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Занято',
                  _formatBytes(used),
                  LiquidTokens.primaryLight,
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: LiquidTokens.glassBorderSubtle,
                ),
                _buildMetricColumn(
                  'Свободно',
                  _formatBytes(free),
                  LiquidTokens.success,
                ),
                Container(
                  width: 1,
                  height: 26,
                  color: LiquidTokens.glassBorderSubtle,
                ),
                _buildMetricColumn(
                  'Всего',
                  _formatBytes(total),
                  LiquidTokens.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: LiquidTokens.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCleanHero(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(LiquidTokens.space16),
      tintColor: LiquidTokens.primary.withValues(alpha: 0.12),
      border: Border.all(
        color: LiquidTokens.primaryLight.withValues(alpha: 0.35),
        width: 1.0,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LiquidTokens.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(LiquidTokens.radiusSm),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: LiquidTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Быстрая очистка',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Сканировать кэш и временный мусор',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: LiquidTokens.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            onPressed: () => _navigateToTab(context, 1, const CleanScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeLabel,
    bool isBadgeProminent = false,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(LiquidTokens.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: LiquidTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          LiquidBadge(
            label: badgeLabel,
            isProminent: isBadgeProminent,
            color: isBadgeProminent ? LiquidTokens.primaryLight : null,
          ),
          const SizedBox(width: 6),
          const Icon(
            LucideIcons.chevronRight,
            size: 16,
            color: LiquidTokens.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyAdvisory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LiquidTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(LiquidTokens.radiusMd),
        border: Border.all(color: LiquidTokens.glassBorderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.shieldCheck,
            size: 20,
            color: LiquidTokens.accent,
          ),
          const SizedBox(width: LiquidTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Принцип безопасной очистки',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Приложение удаляет исключительно временные файлы, кэш и подтверждённые копии. Личные документы, чаты и системные файлы защищены.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the Apple-style circular storage ring with ambient gradient
class _StorageArcPainter extends CustomPainter {
  final double percent;
  final Color primaryColor;
  final Color accentColor;
  final Color trackColor;

  _StorageArcPainter({
    required this.percent,
    required this.primaryColor,
    required this.accentColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 270 degree arc, starting at bottom-left
    const startAngle = 0.75 * math.pi;
    const sweepAngle = 1.5 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active Gradient Paint
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [primaryColor, accentColor],
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final currentSweep = sweepAngle * percent;
    if (currentSweep > 0) {
      canvas.drawArc(rect, startAngle, currentSweep, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StorageArcPainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
