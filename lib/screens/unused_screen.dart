import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/clean_item.dart';
import '../services/scan_service.dart';
import '../services/permission_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class UnusedScreen extends StatefulWidget {
  const UnusedScreen({super.key});

  @override
  State<UnusedScreen> createState() => _UnusedScreenState();
}

class _UnusedScreenState extends State<UnusedScreen> {
  bool _scanning = false;
  List<UnusedApp> _apps = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _scanning = true;
    });
    final insights = await ScanService.scanUnused();
    if (mounted) {
      setState(() {
        _apps = insights;
        _scanning = false;
      });
    }
  }

  void _openSystemSettings() {
    PermissionService.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Память приложений')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: LiquidTokens.space16,
            vertical: LiquidTokens.space8,
          ),
          children: [
            // Hero Platform Security Card
            GlassCard(
              padding: const EdgeInsets.all(LiquidTokens.space20),
              hasGlow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: LiquidTokens.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            LiquidTokens.radiusSm,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          size: 20,
                          color: LiquidTokens.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Безопасность системы',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const LiquidBadge(
                        label: 'Защита данных',
                        color: LiquidTokens.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'В соответствии с политиками безопасности iOS и Android, приватный кэш и данные других приложений изолированы в песочницах (sandboxes). Сторонние приложения не могут удалять чужие данные напрямую.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  LiquidButton(
                    label: 'Настройки хранилища',
                    icon: LucideIcons.externalLink,
                    onPressed: _openSystemSettings,
                  ),
                ],
              ),
            ),
            const SizedBox(height: LiquidTokens.space20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Основные потребители памяти',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Рекомендации',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: LiquidTokens.space12),

            if (_scanning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            else
              ..._apps.map(
                (app) => Padding(
                  padding: const EdgeInsets.only(bottom: LiquidTokens.space10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(LiquidTokens.space16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              LiquidTokens.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.layers,
                            size: 20,
                            color: LiquidTokens.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${app.category} • Не обновлялось ${DateTime.now().difference(app.lastUsed).inDays} дн.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app.sizeLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: LiquidTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: LiquidTokens.space16),

            // How to clean native guide
            Container(
              padding: const EdgeInsets.all(LiquidTokens.space16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(LiquidTokens.radiusMd),
                border: Border.all(color: LiquidTokens.glassBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.helpCircle,
                        size: 18,
                        color: LiquidTokens.primaryLight,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Как освободить ещё больше памяти:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTipStep(
                    '1',
                    'Откройте «Настройки» устройства → «Хранилище» или «Приложения».',
                  ),
                  _buildTipStep(
                    '2',
                    'Выберите ресурсоёмкое приложение (мессенджер, видеосервис или браузер).',
                  ),
                  _buildTipStep(
                    '3',
                    'Нажмите «Очистить кэш» или удалите неиспользуемые загруженные медиафайлы.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTipStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LiquidTokens.primary.withValues(alpha: 0.25),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: LiquidTokens.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: LiquidTokens.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
