import 'package:barista_brew/data/brew_methods_data.dart';
import 'package:barista_brew/models/brew_log.dart';
import 'package:barista_brew/models/coffee_recipe.dart';
import 'package:barista_brew/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState Tests', () {
    test('themeMode cycles correctly', () {
      final state = AppState();
      expect(state.themeMode, ThemeMode.system);

      state.cycleThemeMode();
      expect(state.themeMode, ThemeMode.light);

      state.cycleThemeMode();
      expect(state.themeMode, ThemeMode.dark);

      state.cycleThemeMode();
      expect(state.themeMode, ThemeMode.system);
    });

    test('cross-screen navigation works as expected', () {
      final state = AppState();
      expect(state.activeTabIndex, 0);

      // Start timer with method
      final method = BrewMethodsData.byId('chemex');
      state.startTimerWithMethod(method);
      expect(state.activeTabIndex, 3);
      expect(state.timerSelectedMethod?.id, 'chemex');
      expect(state.timerSelectedRecipe, isNull);

      // Open calculator with ratio
      state.openCalculatorWith(ratio: 15.0, coffee: 30.0);
      expect(state.activeTabIndex, 0);
      expect(state.calcRatio, 15.0);
      expect(state.calcCoffee, 30.0);

      state.clearCalculatorOverrides();
      expect(state.calcRatio, isNull);
      expect(state.calcCoffee, isNull);

      // Start timer with recipe
      final recipe = CoffeeRecipe(
        id: 'rec_1',
        name: 'Test V60',
        methodName: 'V60 (Pour Over)',
        coffeeGrams: 20,
        waterMl: 320,
        ratio: 16,
        grindSize: 'Orta',
        waterTempC: 93,
        totalTimeSeconds: 180,
        notes: 'Enfes aroma',
        createdAt: DateTime.now(),
      );
      state.startTimerWithRecipe(recipe);
      expect(state.activeTabIndex, 3);
      expect(state.timerSelectedRecipe?.id, 'rec_1');
      expect(state.timerSelectedMethod, isNull);
    });

    test('backup JSON export and import restores data correctly', () {
      final state = AppState();

      final recipe = CoffeeRecipe(
        id: 'r_abc',
        name: 'Special Blend',
        methodName: 'Chemex',
        coffeeGrams: 30,
        waterMl: 450,
        ratio: 15,
        grindSize: 'Orta-Kaba',
        waterTempC: 94,
        totalTimeSeconds: 240,
        notes: 'Gül ve yasemin kokusu',
        createdAt: DateTime(2026, 10, 16),
      );
      state.addRecipe(recipe);

      final log = BrewLogEntry(
        id: 'l_xyz',
        date: DateTime(2026, 10, 16, 8, 30),
        methodName: 'Chemex',
        coffeeGrams: 30,
        waterMl: 450,
        ratio: 15,
        grindSize: 'Orta-Kaba',
        waterTempC: 94,
        brewTimeSeconds: 235,
        rating: 5,
        notes: 'Çok dengeli çıktı.',
      );
      state.addLog(log);

      // Export
      final jsonStr = state.exportBackupJson();
      expect(jsonStr, contains('Special Blend'));
      expect(jsonStr, contains('Çok dengeli çıktı.'));

      // New fresh state and import
      final newState = AppState();
      final importSuccess = newState.importBackupJson(jsonStr);
      expect(importSuccess, isTrue);
      expect(newState.recipes.length, 1);
      expect(newState.recipes.first.name, 'Special Blend');
      expect(newState.logs.length, 1);
      expect(newState.logs.first.rating, 5);
    });
  });
}
