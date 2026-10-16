import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'calculator_screen.dart';
import 'journal_screen.dart';
import 'methods_screen.dart';
import 'recipes_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _screens = [
    CalculatorScreen(),
    MethodsScreen(),
    TimerScreen(),
    RecipesScreen(),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = context.watch<AppState>().activeTabIndex;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: [
          for (var index = 0; index < _screens.length; index++)
            IgnorePointer(
              ignoring: index != activeIndex,
              child: ExcludeSemantics(
                excluding: index != activeIndex,
                child: AnimatedOpacity(
                  opacity: index == activeIndex ? 1 : 0,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  curve: Curves.easeInOutCubic,
                  child: _screens[index],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (i) => context.read<AppState>().setActiveTab(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.filter_alt_outlined),
            selectedIcon: Icon(Icons.filter_alt),
            label: 'Methods',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Journal',
          ),
        ],
      ),
    );
  }
}
