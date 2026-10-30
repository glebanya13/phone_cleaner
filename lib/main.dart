import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/clean_screen.dart';
import 'screens/duplicates_screen.dart';
import 'screens/unused_screen.dart';
import 'widgets/ambient_background.dart';
import 'widgets/liquid_navigation_bar.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: PhoneCleanerApp()));
}

class PhoneCleanerApp extends StatelessWidget {
  const PhoneCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Cleaner',
      debugShowCheckedModeBanner: false,
      theme: buildLiquidTheme(Brightness.dark),
      darkTheme: buildLiquidTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _onSelectTab(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSelectTab: _onSelectTab),
      const CleanScreen(),
      const DuplicatesScreen(),
      const UnusedScreen(),
    ];

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: LiquidNavigationBar(
          currentIndex: _index,
          onTap: _onSelectTab,
          items: const [
            LiquidNavItem(icon: LucideIcons.layoutDashboard, label: 'Обзор'),
            LiquidNavItem(icon: LucideIcons.sparkles, label: 'Очистка'),
            LiquidNavItem(icon: LucideIcons.image, label: 'Дубли'),
            LiquidNavItem(icon: LucideIcons.layers, label: 'Память'),
          ],
        ),
      ),
    );
  }
}
