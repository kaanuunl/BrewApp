import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/brew_log.dart';
import '../models/coffee_recipe.dart';

/// Uygulama genelindeki durumu yönetir (reçeteler + günlük) ve
/// cihazda kalıcı olarak saklar.
class AppState extends ChangeNotifier {
  AppState() {
    _load();
  }

  static const _recipesKey = 'bb_recipes';
  static const _logsKey = 'bb_logs';

  final List<CoffeeRecipe> _recipes = [];
  final List<BrewLogEntry> _logs = [];

  List<CoffeeRecipe> get recipes => List.unmodifiable(_recipes);
  List<BrewLogEntry> get logs =>
      List.unmodifiable(_logs..sort((a, b) => b.date.compareTo(a.date)));

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

  // ---- Kalıcılık ----

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesRaw = prefs.getString(_recipesKey);
    final logsRaw = prefs.getString(_logsKey);

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
