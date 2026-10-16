import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/brew_log.dart';
import '../models/brew_method.dart';
import '../models/coffee_recipe.dart';
import '../models/grinder_calibration.dart';

class AppState extends ChangeNotifier {
  AppState() {
    ready = _load().then(
      (_) => Future<void>.delayed(const Duration(milliseconds: 720)),
    );
  }

  late final Future<void> ready;

  static const calculatorTabIndex = 0;
  static const methodsTabIndex = 1;
  static const timerTabIndex = 2;
  static const recipesTabIndex = 3;
  static const journalTabIndex = 4;

  static const _recipesKey = 'bb_recipes';
  static const _logsKey = 'bb_logs';
  static const _themeModeKey = 'bb_theme_mode';
  static const _grinderCalibrationKey = 'bb_grinder_calibration';

  final List<CoffeeRecipe> _recipes = [];
  final List<BrewLogEntry> _logs = [];
  GrinderCalibration? _grinderCalibration;

  List<CoffeeRecipe> get recipes => List.unmodifiable(_recipes);
  List<BrewLogEntry> get logs => List.unmodifiable(_logs);
  GrinderCalibration? get grinderCalibration => _grinderCalibration;

  String? calibratedGrindFor(String methodId) =>
      _grinderCalibration?.settingFor(methodId);

  Future<void> saveGrinderCalibration(GrinderCalibration calibration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _grinderCalibrationKey,
      jsonEncode(calibration.toJson()),
    );
    _grinderCalibration = calibration;
    notifyListeners();
  }

  Future<void> clearGrinderCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_grinderCalibrationKey);
    _grinderCalibration = null;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode();
  }

  void cycleThemeMode() {
    switch (_themeMode) {
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    if (index < calculatorTabIndex || index > journalTabIndex) return;
    if (_activeTabIndex == index) return;
    _activeTabIndex = index;
    notifyListeners();
  }

  BrewMethod? _timerSelectedMethod;
  CoffeeRecipe? _timerSelectedRecipe;

  BrewMethod? get timerSelectedMethod => _timerSelectedMethod;
  CoffeeRecipe? get timerSelectedRecipe => _timerSelectedRecipe;

  void startTimerWithMethod(BrewMethod method) {
    _timerSelectedMethod = method;
    _timerSelectedRecipe = null;
    _activeTabIndex = timerTabIndex;
    notifyListeners();
  }

  void startTimerWithRecipe(CoffeeRecipe recipe) {
    _timerSelectedRecipe = recipe;
    _timerSelectedMethod = null;
    _activeTabIndex = timerTabIndex;
    notifyListeners();
  }

  void clearTimerSelection() {
    _timerSelectedMethod = null;
    _timerSelectedRecipe = null;
  }

  double? _calcRatio;
  double? _calcCoffee;

  double? get calcRatio => _calcRatio;
  double? get calcCoffee => _calcCoffee;

  void openCalculatorWith({required double ratio, double? coffee}) {
    _calcRatio = ratio;
    _calcCoffee = coffee;
    _activeTabIndex = calculatorTabIndex;
    notifyListeners();
  }

  void clearCalculatorOverrides() {
    _calcRatio = null;
    _calcCoffee = null;
  }


  void addRecipe(CoffeeRecipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
    _saveRecipes();
  }

  void updateRecipe(CoffeeRecipe recipe) {
    final i = _recipes.indexWhere((r) => r.id == recipe.id);
    if (i != -1) {
      _recipes[i] = recipe;
      notifyListeners();
      _saveRecipes();
    }
  }

  void deleteRecipe(String id) {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    _saveRecipes();
  }


  void addLog(BrewLogEntry entry) {
    _logs.add(entry);
    _sortLogs();
    notifyListeners();
    _saveLogs();
  }

  void deleteLog(String id) {
    _logs.removeWhere((l) => l.id == id);
    _sortLogs();
    notifyListeners();
    _saveLogs();
  }

  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_recipesKey),
      prefs.remove(_logsKey),
      prefs.remove(_themeModeKey),
      prefs.remove(_grinderCalibrationKey),
    ]);

    _recipes.clear();
    _logs.clear();
    _themeMode = ThemeMode.system;
    _grinderCalibration = null;
    _timerSelectedMethod = null;
    _timerSelectedRecipe = null;
    _calcRatio = null;
    _calcCoffee = null;
    notifyListeners();
  }


  String exportBackupJson() {
    final data = {
      'app': 'Brew App',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'recipes': _recipes.map((r) => r.toJson()).toList(),
      'logs': _logs.map((l) => l.toJson()).toList(),
      if (_grinderCalibration != null)
        'grinderCalibration': _grinderCalibration!.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importBackupJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final recipesRaw = data['recipes'] as List?;
      final logsRaw = data['logs'] as List?;
      final grinderRaw = data['grinderCalibration'];
      final grinderCalibration = grinderRaw == null
          ? null
          : GrinderCalibration.fromJson(grinderRaw as Map<String, dynamic>);

      if (recipesRaw != null) {
        for (final item in recipesRaw) {
          final recipe = CoffeeRecipe.fromJson(item as Map<String, dynamic>);
          final idx = _recipes.indexWhere((r) => r.id == recipe.id);
          if (idx != -1) {
            _recipes[idx] = recipe;
          } else {
            _recipes.add(recipe);
          }
        }
      }

      if (logsRaw != null) {
        for (final item in logsRaw) {
          final log = BrewLogEntry.fromJson(item as Map<String, dynamic>);
          final idx = _logs.indexWhere((l) => l.id == log.id);
          if (idx != -1) {
            _logs[idx] = log;
          } else {
            _logs.add(log);
          }
        }
      }

      _sortLogs();
      if (grinderCalibration != null) {
        _grinderCalibration = grinderCalibration;
        saveGrinderCalibration(grinderCalibration);
      }
      notifyListeners();
      _saveRecipes();
      _saveLogs();
      return true;
    } catch (_) {
      return false;
    }
  }


  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesRaw = prefs.getString(_recipesKey);
    final logsRaw = prefs.getString(_logsKey);
    final themeRaw = prefs.getString(_themeModeKey);
    final grinderRaw = prefs.getString(_grinderCalibrationKey);

    if (themeRaw != null) {
      if (themeRaw == 'light') _themeMode = ThemeMode.light;
      if (themeRaw == 'dark') _themeMode = ThemeMode.dark;
      if (themeRaw == 'system') _themeMode = ThemeMode.system;
    }

    if (grinderRaw != null) {
      try {
        _grinderCalibration = GrinderCalibration.fromJson(
          jsonDecode(grinderRaw) as Map<String, dynamic>,
        );
      } catch (_) {
        _grinderCalibration = null;
      }
    }

    if (recipesRaw != null) {
      try {
        final list = jsonDecode(recipesRaw) as List;
        _recipes
          ..clear()
          ..addAll(
            list.map((e) => CoffeeRecipe.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {}
    }

    if (logsRaw != null) {
      try {
        final list = jsonDecode(logsRaw) as List;
        _logs
          ..clear()
          ..addAll(
            list.map((e) => BrewLogEntry.fromJson(e as Map<String, dynamic>)),
          );
        _sortLogs();
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = _themeMode == ThemeMode.light
        ? 'light'
        : _themeMode == ThemeMode.dark
        ? 'dark'
        : 'system';
    await prefs.setString(_themeModeKey, val);
  }

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recipesKey,
      jsonEncode(_recipes.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _logsKey,
      jsonEncode(_logs.map((l) => l.toJson()).toList()),
    );
  }

  void _sortLogs() {
    _logs.sort((a, b) => b.date.compareTo(a.date));
  }
}
