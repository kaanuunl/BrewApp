import 'package:flutter/material.dart';

/// Zorluk seviyesi.
enum Difficulty {
  kolay('Kolay'),
  orta('Orta'),
  zor('İleri');

  const Difficulty(this.label);
  final String label;
}

/// Bir demleme adımı (ör. bloom, ilk döküş, ikinci döküş...).
class BrewStep {
  final String title;
  final String description;
  final int? durationSeconds; // null ise süre belirtilmemiş

  const BrewStep({
    required this.title,
    required this.description,
    this.durationSeconds,
  });
}

/// Bir demleme yöntemi (V60, Chemex, Espresso vb.).
class BrewMethod {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final IconData icon;
  final double ratio; // 1:X  → kahve:su oranı (ör. 16 → 1:16)
  final double defaultCoffeeGrams;
  final String grindSize;
  final int waterTempC;
  final int bloomSeconds;
  final int totalTimeSeconds;
  final Difficulty difficulty;
  final List<BrewStep> steps;
  final List<String> tips;

  const BrewMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.ratio,
    required this.defaultCoffeeGrams,
    required this.grindSize,
    required this.waterTempC,
    required this.bloomSeconds,
    required this.totalTimeSeconds,
    required this.difficulty,
    required this.steps,
    required this.tips,
  });

  /// Verilen kahve gramajı için su miktarı (ml).
  double waterForCoffee(double coffee) => coffee * ratio;

  /// Verilen su miktarı (ml) için kahve gramajı.
  double coffeeForWater(double water) => water / ratio;
}
