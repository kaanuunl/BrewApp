import 'package:flutter/material.dart';

enum Difficulty {
  kolay('Easy'),
  orta('Intermediate'),
  zor('Advanced');

  const Difficulty(this.label);
  final String label;
}

class BrewStep {
  final String title;
  final String description;
  final int? durationSeconds;

  const BrewStep({
    required this.title,
    required this.description,
    this.durationSeconds,
  });
}

class BrewMethod {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final IconData icon;
  final double ratio;
  final String ratioOutputLabel;
  final String ratioOutputUnit;
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
    this.ratioOutputLabel = 'Water',
    this.ratioOutputUnit = 'ml',
    required this.defaultCoffeeGrams,
    required this.grindSize,
    required this.waterTempC,
    required this.bloomSeconds,
    required this.totalTimeSeconds,
    required this.difficulty,
    required this.steps,
    required this.tips,
  });

  double outputForCoffee(double coffee) => coffee * ratio;

  double coffeeForOutput(double output) => output / ratio;
}
