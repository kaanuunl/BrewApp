import 'package:flutter/material.dart';

import '../models/brew_method.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Bir yöntemin detay sayfası: parametreler, adımlar ve püf noktaları.
class MethodDetailScreen extends StatelessWidget {
  const MethodDetailScreen({super.key, required this.method});
  final BrewMethod method;

  @override
  Widget build(BuildContext context) {
    final water = method.waterForCoffee(method.defaultCoffeeGrams);
    final totalStepsSeconds = method.steps.fold<int>(
        0, (sum, s) => sum + (s.durationSeconds ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text(method.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _Hero(method: method),
          const SizedBox(height: 16),
          Text(method.description,
              style: TextStyle(
                  fontSize: 15, height: 1.5, color: AppColors.espresso.withValues(alpha: 0.9))),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatTile(
                icon: Icons.scale_outlined,
                label: 'Oran',
                value: fmtRatio(method.ratio),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.grain_outlined,
                label: 'Öğütüm',
                value: method.grindSize.split(' ').first,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatTile(
                icon: Icons.thermostat_outlined,
                label: 'Su sıcaklığı',
                value: '${method.waterTempC}°C',
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.timer_outlined,
                label: 'Toplam süre',
                value: fmtLongDuration(method.totalTimeSeconds),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Varsayılan ölçü'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.milk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _KeyValue('Kahve', '${fmtNum(method.defaultCoffeeGrams)} g'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.latte,
                ),
                Expanded(
                  child: _KeyValue('Su', '${fmtNum(water)} ml'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Adımlar'),
          const SizedBox(height: 10),
          for (var i = 0; i < method.steps.length; i++)
            _StepTile(
              index: i + 1,
              step: method.steps[i],
              isLast: i == method.steps.length - 1,
            ),
          if (totalStepsSeconds > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Adım süreleri toplamı: ${fmtLongDuration(totalStepsSeconds)}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.coffee),
            ),
          ],
          const SizedBox(height: 24),
          const _SectionTitle('Püf noktaları'),
          const SizedBox(height: 10),
          for (final tip in method.tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.verified_outlined,
                        size: 18, color: AppColors.caramel),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tip,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: AppColors.espresso.withValues(alpha: 0.9))),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.method});
  final BrewMethod method;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.coffee, AppColors.espresso],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(method.icon, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method.subtitle,
                  style: TextStyle(
                      color: AppColors.coffee,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.milk,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Zorluk: ${method.difficulty.label}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.espresso,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.espresso));
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.foam,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.latte),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.caramel, size: 20),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.coffee)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espresso)),
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.coffee)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.espresso)),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.step,
    required this.isLast,
  });
  final int index;
  final BrewStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.coffee,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('$index',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: AppColors.latte),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(step.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    if (step.durationSeconds != null)
                      Text(fmtDuration(step.durationSeconds!),
                          style: const TextStyle(
                              color: AppColors.caramel,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(step.description,
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: AppColors.espresso.withValues(alpha: 0.85))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
