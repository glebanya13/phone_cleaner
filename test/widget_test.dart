import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_cleaner/main.dart';
import 'package:phone_cleaner/models/clean_item.dart';
import 'package:phone_cleaner/widgets/glass_card.dart';
import 'package:phone_cleaner/widgets/liquid_navigation_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  testWidgets('PhoneCleanerApp mounts and displays navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PhoneCleanerApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Обзор'), findsOneWidget);
    expect(find.text('Очистка'), findsOneWidget);
    expect(find.text('Дубли'), findsOneWidget);
    expect(find.text('Память'), findsOneWidget);
  });

  testWidgets('LiquidButton triggers callback when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LiquidButton(
            label: 'Тестовая кнопка',
            icon: LucideIcons.sparkles,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Тестовая кнопка'), findsOneWidget);
    await tester.tap(find.text('Тестовая кнопка'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('LiquidBadge renders label and icon', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LiquidBadge(label: 'Активно', isProminent: true)),
      ),
    );

    expect(find.text('Активно'), findsOneWidget);
  });

  test('CleanItem computes size labels correctly', () {
    final itemMb = CleanItem(
      id: '1',
      title: 'Кэш',
      subtitle: 'Подзаголовок',
      sizeBytes: 15 * 1024 * 1024,
      icon: LucideIcons.database,
    );
    expect(itemMb.sizeLabel, '15.0 МБ');

    final itemGb = CleanItem(
      id: '2',
      title: 'Большой файл',
      subtitle: 'Подзаголовок',
      sizeBytes: 2 * 1024 * 1024 * 1024,
      icon: LucideIcons.file,
    );
    expect(itemGb.sizeLabel, '2.00 ГБ');

    final itemKb = CleanItem(
      id: '3',
      title: 'Лог',
      subtitle: 'Подзаголовок',
      sizeBytes: 512 * 1024,
      icon: LucideIcons.fileText,
    );
    expect(itemKb.sizeLabel, '512 КБ');
  });

  test('DuplicateGroup computes reclaimable size accurately', () {
    final group = DuplicateGroup(
      id: 'dup_1',
      paths: ['/a/1.jpg', '/a/2.jpg', '/a/3.jpg'],
      sizeBytes: 30 * 1024 * 1024, // 3 copies of 10MB each
    );

    // Keeping 1 original, reclaiming 2 copies = 20MB
    expect(group.reclaimableBytes, 20 * 1024 * 1024);
    expect(group.reclaimableLabel, '20.0 МБ');
    expect(group.count, 3);
  });

  testWidgets('LiquidNavigationBar switches tab when clicked', (
    WidgetTester tester,
  ) async {
    int selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidNavigationBar(
            currentIndex: selected,
            onTap: (idx) {
              selected = idx;
            },
            items: const [
              LiquidNavItem(icon: LucideIcons.layoutDashboard, label: 'Обзор'),
              LiquidNavItem(icon: LucideIcons.sparkles, label: 'Очистка'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Обзор'), findsOneWidget);
    expect(find.text('Очистка'), findsOneWidget);

    await tester.tap(find.text('Очистка'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });
}
