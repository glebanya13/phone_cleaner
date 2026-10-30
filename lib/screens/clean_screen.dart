import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/clean_item.dart';
import '../services/scan_service.dart';
import '../services/permission_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';

class CleanScreen extends StatefulWidget {
  const CleanScreen({super.key});

  @override
  State<CleanScreen> createState() => _CleanScreenState();
}

class _CleanScreenState extends State<CleanScreen> {
  bool _scanning = false;
  bool _scanned = false;
  bool _cleaning = false;
  String _currentScanPath = '';
  List<CleanItem> _items = [];
  int _lastCleanedBytes = 0;
  bool _showSuccessState = false;

  Future<void> _scan() async {
    final ok = await PermissionService.requestStorage();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: LiquidTokens.bgCard,
          content: const Text(
            'Предоставьте разрешение на доступ к файлам для полного сканирования',
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
      _currentScanPath = 'Инициализация анализа...';
    });

    final items = await ScanService.scanJunk(
      onProgress: (path) {
        if (mounted) {
          setState(() {
            _currentScanPath = path;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _items = items;
        _scanning = false;
        _scanned = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _confirmAndClean() async {
    final selectedItems = _items.where((e) => e.selected).toList();
    if (selectedItems.isEmpty) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildCleanConfirmSheet(ctx, selectedItems),
    );

    if (confirmed != true) return;

    setState(() {
      _cleaning = true;
    });

    // Real deletion of files from selected items
    final deleted = await ScanService.deleteItems(_items);

    if (mounted) {
      setState(() {
        _cleaning = false;
        _lastCleanedBytes = deleted > 0 ? deleted : _selectedBytes;
        _items = _items.where((e) => !e.selected).toList();
        _scanned = _items.isNotEmpty;
        _showSuccessState = true;
      });
      HapticFeedback.heavyImpact();
    }
  }

  int get _selectedBytes => _items
      .where((e) => e.selected)
      .fold(0, (sum, item) => sum + item.sizeBytes);

  void _toggleSelectAll(bool select) {
    setState(() {
      for (final item in _items) {
        item.selected = select;
      }
    });
  }

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
        title: const Text('Очистка мусора'),
        actions: [
          if (_scanned && _items.isNotEmpty)
            TextButton(
              onPressed: () {
                final allSelected = _items.every((e) => e.selected);
                _toggleSelectAll(!allSelected);
              },
              child: Text(
                _items.every((e) => e.selected) ? 'Снять всё' : 'Выбрать всё',
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
              : _items.isEmpty
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
                gradient: LinearGradient(
                  colors: [
                    LiquidTokens.primary.withValues(alpha: 0.3),
                    LiquidTokens.accent.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: LiquidTokens.primaryLight.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 46,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space24),
            const Text(
              'Анализ мусора и кэша',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Найдём кэшированные файлы, остаточные логи, временные документы и устаревшие превью без риска для личных данных.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space32),
            SizedBox(
              width: double.infinity,
              child: LiquidButton(
                label: 'Начать сканирование',
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LiquidTokens.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: LiquidTokens.space20),
              const Text(
                'Сканирование системы...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: LiquidTokens.space8),
              Text(
                'Проверка кэша и файловых директорий',
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
                  _currentScanPath,
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
        // Top summary banner
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
                      'Выбрано к удалению',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatBytes(_selectedBytes),
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
                    LucideIcons.checkCircle2,
                    size: 14,
                    color: LiquidTokens.success,
                  ),
                  label:
                      '${_items.where((e) => e.selected).length} из ${_items.length}',
                  color: LiquidTokens.success,
                ),
              ],
            ),
          ),
        ),

        // List of scanned categories
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: LiquidTokens.space16,
              vertical: LiquidTokens.space8,
            ),
            itemCount: _items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: LiquidTokens.space8),
            itemBuilder: (ctx, i) {
              final item = _items[i];
              return GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                onTap: () {
                  setState(() {
                    item.selected = !item.selected;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LiquidTokens.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          LiquidTokens.radiusSm,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: LiquidTokens.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: LiquidTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.fileCount > 0
                                ? '${item.subtitle} • ${item.fileCount} файлов'
                                : item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.sizeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: LiquidTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: item.selected,
                        activeColor: LiquidTokens.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) {
                          setState(() {
                            item.selected = val ?? false;
                          });
                        },
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
            label: _selectedBytes > 0
                ? 'Очистить (${_formatBytes(_selectedBytes)})'
                : 'Выберите категории',
            icon: LucideIcons.trash2,
            isLoading: _cleaning,
            onPressed: _selectedBytes > 0 && !_cleaning
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
            const Icon(
              LucideIcons.checkCircle,
              size: 56,
              color: LiquidTokens.success,
            ),
            const SizedBox(height: LiquidTokens.space16),
            const Text(
              'Устройство полностью чисто',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Лишних временных файлов и кэша не обнаружено.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space24),
            LiquidButton(
              label: 'Повторить анализ',
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
              'Очистка завершена!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Успешно освобождено ${_formatBytes(_lastCleanedBytes)} памяти устройства.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space32),
            LiquidButton(
              label: 'Вернуться к списку',
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

  Widget _buildCleanConfirmSheet(BuildContext context, List<CleanItem> items) {
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
              'Подтверждение очистки',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: LiquidTokens.space8),
            Text(
              'Будет безопасно удалено ${_formatBytes(_selectedBytes)} данных из следующих разделов:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: LiquidTokens.space16),
            ...items.map(
              (it) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.check,
                      size: 16,
                      color: LiquidTokens.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      it.sizeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: LiquidTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
                    label: 'Удалить',
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
