import 'package:brew_app/data/brew_methods_data.dart';
import 'package:brew_app/models/brew_log.dart';
import 'package:brew_app/models/coffee_recipe.dart';
import 'package:brew_app/models/grinder_calibration.dart';
import 'package:brew_app/state/app_state.dart';
import 'package:brew_app/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppState Tests', () {
    test('number formatting follows the device locale with English time units', () {
      Intl.defaultLocale = 'tr_TR';
      expect(fmtNum(1.5), '1,5');
      expect(fmtLongDuration(90), '1,5m');

      Intl.defaultLocale = 'en_US';
      expect(fmtNum(1.5), '1.5');
      expect(fmtLongDuration(90), '1.5m');

      Intl.defaultLocale = 'tr_TR';
    });

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

      final method = BrewMethodsData.byId('chemex');
      state.startTimerWithMethod(method);
      expect(state.activeTabIndex, AppState.timerTabIndex);
      expect(state.timerSelectedMethod?.id, 'chemex');
      expect(state.timerSelectedRecipe, isNull);

      state.openCalculatorWith(ratio: 15.0, coffee: 30.0);
      expect(state.activeTabIndex, 0);
      expect(state.calcRatio, 15.0);
      expect(state.calcCoffee, 30.0);

      state.clearCalculatorOverrides();
      expect(state.calcRatio, isNull);
      expect(state.calcCoffee, isNull);

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
      expect(state.activeTabIndex, AppState.timerTabIndex);
      expect(state.timerSelectedRecipe?.id, 'rec_1');
      expect(state.timerSelectedMethod, isNull);
    });

    test(
      'brew method step durations match their displayed total durations',
      () {
        for (final method in BrewMethodsData.all) {
          final stepsTotal = method.steps.fold<int>(
            0,
            (sum, step) => sum + (step.durationSeconds ?? 0),
          );

          expect(
            stepsTotal,
            method.totalTimeSeconds,
            reason: '${method.name} step and total durations should agree',
          );
        }
      },
    );

    test('espresso ratio represents beverage yield rather than brew water', () {
      final espresso = BrewMethodsData.byId('espresso');

      expect(espresso.ratio, 2);
      expect(espresso.outputForCoffee(18), 36);
      expect(espresso.ratioOutputLabel, 'Espresso yield');
      expect(espresso.ratioOutputUnit, 'g');
    });

    test('legacy Turkish method names resolve to their English methods', () {
      expect(BrewMethodsData.byName('Türk Kahvesi').id, 'turkish');
      expect(BrewMethodsData.byName('Sifon (Syphon)').id, 'siphon');
    });

    test('legacy grinder units are displayed in English', () {
      final calibration = GrinderCalibration.fromJson({
        'grinderName': 'Test grinder',
        'unit': 'klik',
        'settings': {'v60': '18'},
        'updatedAt': DateTime(2026, 10, 16).toIso8601String(),
      });

      expect(calibration.unit, 'clicks');
    });

    test('new brew methods are available with complete timed steps', () {
      final ids = BrewMethodsData.all.map((method) => method.id).toSet();

      expect(
        ids,
        containsAll([
          'kalita',
          'clever',
          'siphon',
          'phin',
          'batchbrew',
          'switch',
          'origami',
          'colddrip',
        ]),
      );
    });

    test(
      'popular calibration profiles prioritize espresso and common methods',
      () {
        expect(BrewMethodsData.calibrationPriority.first.id, 'espresso');
        expect(BrewMethodsData.popular.map((method) => method.id).toList(), [
          'v60',
          'batchbrew',
          'frenchpress',
          'moka',
          'aeropress',
          'chemex',
          'coldbrew',
        ]);
      },
    );

    test('grinder calibration persists by method and can be cleared', () async {
      final state = AppState();
      final calibration = GrinderCalibration(
        grinderName: 'Test grinder',
        unit: 'klik',
        settings: const {'v60': '18'},
        updatedAt: DateTime(2026, 10, 16),
      );

      await state.saveGrinderCalibration(calibration);

      expect(state.calibratedGrindFor('v60'), '18');
      expect(state.calibratedGrindFor('chemex'), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('bb_grinder_calibration'), isNotNull);

      await state.clearGrinderCalibration();

      expect(state.grinderCalibration, isNull);
      expect(prefs.containsKey('bb_grinder_calibration'), isFalse);
    });

    test(
      'logs stay newest first and reading them does not reorder them again',
      () {
        final state = AppState();
        final olderLog = BrewLogEntry(
          id: 'older',
          date: DateTime(2026, 10, 1),
          methodName: 'V60',
          coffeeGrams: 18,
          waterMl: 288,
          ratio: 16,
          grindSize: 'Orta-ince',
          waterTempC: 94,
          brewTimeSeconds: 180,
          rating: 4,
          notes: '',
        );
        final newerLog = BrewLogEntry(
          id: 'newer',
          date: DateTime(2026, 10, 2),
          methodName: 'Chemex',
          coffeeGrams: 30,
          waterMl: 450,
          ratio: 15,
          grindSize: 'Orta-kaba',
          waterTempC: 94,
          brewTimeSeconds: 240,
          rating: 5,
          notes: '',
        );

        state.addLog(olderLog);
        state.addLog(newerLog);

        expect(state.logs.map((log) => log.id), ['newer', 'older']);
        expect(state.logs.map((log) => log.id), ['newer', 'older']);
      },
    );

    test(
      'clearing local data removes saved user data and resets theme',
      () async {
        final state = AppState();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        state.addRecipe(
          CoffeeRecipe(
            id: 'to_delete',
            name: 'Delete me',
            methodName: 'V60',
            coffeeGrams: 18,
            waterMl: 288,
            ratio: 16,
            grindSize: 'Orta-ince',
            waterTempC: 94,
            totalTimeSeconds: 180,
            notes: '',
            createdAt: DateTime(2026, 10, 16),
          ),
        );
        state.setThemeMode(ThemeMode.dark);
        await state.saveGrinderCalibration(
          GrinderCalibration(
            grinderName: 'Test grinder',
            unit: 'klik',
            settings: const {'v60': '18'},
            updatedAt: DateTime(2026, 10, 16),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await state.clearLocalData();
        final prefs = await SharedPreferences.getInstance();

        expect(state.recipes, isEmpty);
        expect(state.logs, isEmpty);
        expect(state.themeMode, ThemeMode.system);
        expect(prefs.containsKey('bb_recipes'), isFalse);
        expect(prefs.containsKey('bb_logs'), isFalse);
        expect(prefs.containsKey('bb_theme_mode'), isFalse);
        expect(prefs.containsKey('bb_grinder_calibration'), isFalse);
      },
    );

    test('backup JSON export and import restores data correctly', () async {
      final state = AppState();
      await state.saveGrinderCalibration(
        GrinderCalibration(
          grinderName: 'Test grinder',
          unit: 'klik',
          settings: const {'chemex': '22'},
          updatedAt: DateTime(2026, 10, 16),
        ),
      );

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

      final jsonStr = state.exportBackupJson();
      expect(jsonStr, contains('Special Blend'));
      expect(jsonStr, contains('Çok dengeli çıktı.'));
      expect(jsonStr, contains('Test grinder'));

      final newState = AppState();
      final importSuccess = newState.importBackupJson(jsonStr);
      expect(importSuccess, isTrue);
      expect(newState.recipes.length, 1);
      expect(newState.recipes.first.name, 'Special Blend');
      expect(newState.logs.length, 1);
      expect(newState.logs.first.rating, 5);
      expect(newState.calibratedGrindFor('chemex'), '22');
    });
  });
}
