import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/clean_item.dart';
import '../services/scan_service.dart';
import '../services/permission_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class DuplicatesScreen extends StatefulWidget {
  const DuplicatesScreen({super.key});

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {
  bool _scanning = false;
  bool _scanned = false;
  bool _cleaning = false;
  String _currentScanFile = '';
  List<DuplicateGroup> _groups = [];
  int _lastReclaimedBytes = 0;
  bool _showSuccessState = false;

  Future<void> _scan() async {
    final ok = await PermissionService.requestStorage();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LiquidTokens.bgCard,
          content: const Text(
            'Необходим доступ к фотографиям для поиска дубликатов',
            style: TextStyle(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Настройки',
            textColor: LiquidTokens.accent,
            onPressed: PermissionService.openSettings,
          ),
        ),
      );
    }

    setState(() {
      _scanning = true;
      _scanned = false;
      _showSuccessState = false;
      _currentScanFile = 'Поиск изображений в галерее...';
    });

    final groups = await ScanService.scanDuplicates(
      onProgress: (path) {
        if (mounted) {
          setState(() {
            _currentScanFile = path;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _groups = groups;
        _scanning = false;
        _scanned = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _confirmAndClean() async {
    final selectedGroups = _groups.where((g) => g.selected).toList();
    if (selectedGroups.isEmpty) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildCleanConfirmSheet(ctx, selectedGroups),
    );

    if (confirmed != true) return;

    setState(() {
      _cleaning = true;
    });

    final reclaimed = await ScanService.deleteDuplicates(_groups);

    if (mounted) {
      setState(() {
        _cleaning = false;
        _lastReclaimedBytes = reclaimed > 0
            ? reclaimed
            : _selectedReclaimableBytes;
        _groups = _groups.where((g) => !g.selected).toList();
        _scanned = _groups.isNotEmpty;
        _showSuccessState = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  int get _selectedReclaimableBytes => _groups
      .where((g) => g.selected)
      .fold(0, (sum, g) => sum + g.reclaimableBytes);

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} КБ';
    }
    return '$bytes Б';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Дубликаты фото'),
        actions: [
          if (_scanned && _groups.isNotEmpty)
            TextButton(
              onPressed: () {
                final allSelected = _groups.every((g) => g.selected);
                setState(() {
                  for (final g in _groups) {
                    g.selected = !allSelected;
                  }
                });
              },
              child: Text(
                _groups.every((g) => g.selected) ? 'Снять всё' : 'Выбрать всё',
                style: const TextStyle(
                  color: LiquidTokens.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showSuccessState
              ? _buildSuccessView()
              : _scanning
              ? _buildScanningView()
              : !_scanned
              ? _buildIdleView()
              : _groups.isEmpty
              ? _buildEmptyView()
              : _buildResultsView(),
        ),
      ),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LiquidTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFC084FC), LiquidTokens.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC084FC).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.image,
                size: 46,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space24),
            const Text(
              'Поиск дубликатов фото',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Точный попиксельный и хэш-анализ медиатеки. Мы сохраняем один лучший оригинал и безопасно удаляем одинаковые копии.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space32),
            SizedBox(
              width: double.infinity,
              child: LiquidButton(
                label: 'Сканировать галерею',
                icon: LucideIcons.search,
                onPressed: _scan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LiquidTokens.space32),
        child: GlassCard(
          padding: const EdgeInsets.all(LiquidTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC084FC)),
                ),
              ),
              const SizedBox(height: LiquidTokens.space20),
              const Text(
                'Анализ фотоальбомов...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: LiquidTokens.space8),
              Text(
                'Сравнение контрольных сумм изображений',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: LiquidTokens.space16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(LiquidTokens.radiusSm),
                ),
                child: Text(
                  _currentScanFile,
                  style: const TextStyle(
                    fontSize: 11,
                    color: LiquidTokens.textTertiary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        // Summary Card
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LiquidTokens.space16,
            vertical: LiquidTokens.space8,
          ),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Можно освободить',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatBytes(_selectedReclaimableBytes),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                LiquidBadge(
                  icon: const Icon(
                    LucideIcons.copy,
                    size: 14,
                    color: Color(0xFFC084FC),
                  ),
                  label: '${_groups.length} групп дублей',
                  color: const Color(0xFFC084FC),
                ),
              ],
            ),
          ),
        ),

        // Groups List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: LiquidTokens.space16,
              vertical: LiquidTokens.space8,
            ),
            itemCount: _groups.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: LiquidTokens.space12),
            itemBuilder: (ctx, i) {
              final group = _groups[i];
              return GlassCard(
                padding: const EdgeInsets.all(LiquidTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC084FC,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                LucideIcons.copy,
                                size: 16,
                                color: Color(0xFFC084FC),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Серия ${i + 1}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            LiquidBadge(label: '${group.count} копии'),
                          ],
                        ),
                        Checkbox(
                          value: group.selected,
                          activeColor: LiquidTokens.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              group.selected = val ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Освободит: ${group.reclaimableLabel} (1 оригинал будет сохранён)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: LiquidTokens.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // File path preview chips
                    ...group.paths
                        .take(2)
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.fileImage,
                                  size: 13,
                                  color: LiquidTokens.textTertiary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    p.split(Platform.pathSeparator).last,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: LiquidTokens.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom CTA Bar
        Container(
          padding: const EdgeInsets.only(
            left: LiquidTokens.space16,
            right: LiquidTokens.space16,
            top: LiquidTokens.space12,
            bottom: 95,
          ),
          child: LiquidButton(
            label: _selectedReclaimableBytes > 0
                ? 'Удалить копии (${_formatBytes(_selectedReclaimableBytes)})'
                : 'Выберите дубликаты',
            icon: LucideIcons.trash2,
            isLoading: _cleaning,
            onPressed: _selectedReclaimableBytes > 0 && !_cleaning
                ? _confirmAndClean
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LiquidTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LiquidTokens.success.withValues(alpha: 0.15),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 40,
                color: LiquidTokens.success,
              ),
            ),
            const SizedBox(height: LiquidTokens.space20),
            const Text(
              'Дубликатов не найдено',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'В просканированных папках галереи нет повторяющихся снимков. Медиатека в идеальном порядке.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space24),
            LiquidButton(
              label: 'Повторить поиск',
              icon: LucideIcons.rotateCcw,
              isSecondary: true,
              onPressed: _scan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LiquidTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LiquidTokens.success.withValues(alpha: 0.15),
                border: Border.all(color: LiquidTokens.success, width: 2),
              ),
              child: const Icon(
                LucideIcons.check,
                size: 40,
                color: LiquidTokens.success,
              ),
            ),
            const SizedBox(height: LiquidTokens.space24),
            const Text(
              'Дубликаты удалены',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Успешно освобождено ${_formatBytes(_lastReclaimedBytes)}. Оригинальные снимки бережно сохранены.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space32),
            LiquidButton(
              label: 'Готово',
              isSecondary: true,
              onPressed: () {
                setState(() {
                  _showSuccessState = false;
                  _scanned = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanConfirmSheet(
    BuildContext context,
    List<DuplicateGroup> groups,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(LiquidTokens.radiusXl),
      ),
      child: GlassCard(
        radius: 0,
        padding: const EdgeInsets.all(LiquidTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: LiquidTokens.space20),
            const Text(
              'Удаление дубликатов',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Будут удалены только лишние копии (${_formatBytes(_selectedReclaimableBytes)}). В каждой группе гарантированно сохраняется один исходный файл.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space24),
            Row(
              children: [
                Expanded(
                  child: LiquidButton(
                    label: 'Отмена',
                    isSecondary: true,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: LiquidTokens.space12),
                Expanded(
                  child: LiquidButton(
                    label: 'Удалить копии',
                    isDestructive: true,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
