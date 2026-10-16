import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'calculator_screen.dart';
import 'journal_screen.dart';
import 'methods_screen.dart';
import 'recipes_screen.dart';
import 'timer_screen.dart';

/// Uygulamanın ana iskeleti: alt gezinme çubuğu + 5 sekme.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _screens = [
    CalculatorScreen(),
    MethodsScreen(),
    RecipesScreen(),
    TimerScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<AppState>().activeTabIndex;

    return Scaffold(
      body: IndexedStack(index: activeIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (i) => context.read<AppState>().setActiveTab(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Hesap',
          ),
          NavigationDestination(
            icon: Icon(Icons.filter_alt_outlined),
            selectedIcon: Icon(Icons.filter_alt),
            label: 'Yöntemler',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Reçeteler',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Zamanlayıcı',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Günlük',
          ),
        ],
      ),
    );
  }
}
