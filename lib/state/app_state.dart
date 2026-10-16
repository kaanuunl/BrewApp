import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/brew_log.dart';
import '../models/brew_method.dart';
import '../models/coffee_recipe.dart';

/// Uygulama genelindeki durumu yönetir (reçeteler, günlük, tema ve navigasyon) ve
/// cihazda kalıcı olarak saklar.
class AppState extends ChangeNotifier {
  AppState() {
    _load();
  }

  static const _recipesKey = 'bb_recipes';
  static const _logsKey = 'bb_logs';
  static const _themeModeKey = 'bb_theme_mode';

  final List<CoffeeRecipe> _recipes = [];
  final List<BrewLogEntry> _logs = [];

  List<CoffeeRecipe> get recipes => List.unmodifiable(_recipes);
  List<BrewLogEntry> get logs =>
      List.unmodifiable(_logs..sort((a, b) => b.date.compareTo(a.date)));

  // ---- Tema Durumu ----
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

  // ---- Navigasyon & Ekranlar Arası Veri Aktarımı ----
  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
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
    _activeTabIndex = 3; // Zamanlayıcı sekmesi
    notifyListeners();
  }

  void startTimerWithRecipe(CoffeeRecipe recipe) {
    _timerSelectedRecipe = recipe;
    _timerSelectedMethod = null;
    _activeTabIndex = 3; // Zamanlayıcı sekmesi
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
    _activeTabIndex = 0; // Hesaplayıcı sekmesi
    notifyListeners();
  }

  void clearCalculatorOverrides() {
    _calcRatio = null;
    _calcCoffee = null;
  }

  // ---- Reçeteler ----

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

  // ---- Günlük ----

  void addLog(BrewLogEntry entry) {
    _logs.add(entry);
    notifyListeners();
    _saveLogs();
  }

  void deleteLog(String id) {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
    _saveLogs();
  }

  // ---- Veri Yedekleme & Geri Yükleme ----

  String exportBackupJson() {
    final data = {
      'app': 'BaristaBrew',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'recipes': _recipes.map((r) => r.toJson()).toList(),
      'logs': _logs.map((l) => l.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  bool importBackupJson(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final recipesRaw = data['recipes'] as List?;
      final logsRaw = data['logs'] as List?;

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

      notifyListeners();
      _saveRecipes();
      _saveLogs();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Kalıcılık ----

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesRaw = prefs.getString(_recipesKey);
    final logsRaw = prefs.getString(_logsKey);
    final themeRaw = prefs.getString(_themeModeKey);

    if (themeRaw != null) {
      if (themeRaw == 'light') _themeMode = ThemeMode.light;
      if (themeRaw == 'dark') _themeMode = ThemeMode.dark;
      if (themeRaw == 'system') _themeMode = ThemeMode.system;
    }

    if (recipesRaw != null) {
      try {
        final list = jsonDecode(recipesRaw) as List;
        _recipes
          ..clear()
          ..addAll(
              list.map((e) => CoffeeRecipe.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    if (logsRaw != null) {
      try {
        final list = jsonDecode(logsRaw) as List;
        _logs
          ..clear()
          ..addAll(
              list.map((e) => BrewLogEntry.fromJson(e as Map<String, dynamic>)));
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
        _recipesKey, jsonEncode(_recipes.map((r) => r.toJson()).toList()));
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _logsKey, jsonEncode(_logs.map((l) => l.toJson()).toList()));
  }
}
