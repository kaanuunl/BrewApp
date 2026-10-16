import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brew_method.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class MethodDetailScreen extends StatelessWidget {
  const MethodDetailScreen({super.key, required this.method});
  final BrewMethod method;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calibratedGrind = appState.calibratedGrindFor(method.id);
    final output = method.outputForCoffee(method.defaultCoffeeGrams);
    final totalStepsSeconds = method.steps.fold<int>(
      0,
      (sum, s) => sum + (s.durationSeconds ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text(method.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _Hero(method: method),
          const SizedBox(height: 16),
          Text(
            method.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: context.textPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderLatte),
            ),
            child: Text(
              'This profile is a repeatable starting recipe. Adjust grind, ratio, and time based on the coffee, its freshness, your water, equipment, and tasting results.',
              style: TextStyle(
                color: context.textPrimary,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<AppState>().startTimerWithMethod(method);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('Start timer'),
                ),
              ),
              if (method.id != 'espresso') ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AppState>().openCalculatorWith(
                      ratio: method.ratio,
                      coffee: method.defaultCoffeeGrams,
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.calculate_outlined, size: 18),
                  label: const Text('Calculate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.accentCoffee,
                    side: BorderSide(color: context.borderLatte),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatTile(
                icon: Icons.scale_outlined,
                label: 'Ratio',
                value: fmtRatio(method.ratio),
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.grain_outlined,
                label: calibratedGrind == null
                    ? 'Grind'
                    : 'Grinder setting',
                value: calibratedGrind == null
                    ? method.grindSize
                    : '$calibratedGrind ${appState.grinderCalibration?.unit ?? 'clicks'}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatTile(
                icon: Icons.thermostat_outlined,
                label: 'Water temperature',
                value: '${method.waterTempC}°C',
              ),
              const SizedBox(width: 10),
              _StatTile(
                icon: Icons.timer_outlined,
                label: 'Total time',
                value: fmtLongDuration(method.totalTimeSeconds),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('Default recipe', color: context.textPrimary),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _KeyValue(
                    'Coffee',
                    '${fmtNum(method.defaultCoffeeGrams)} g',
                  ),
                ),
                Container(width: 1, height: 40, color: context.borderLatte),
                Expanded(
                  child: _KeyValue(
                    method.ratioOutputLabel,
                    '${fmtNum(output)} ${method.ratioOutputUnit}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Steps', color: context.textPrimary),
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
              'Total step time: ${fmtLongDuration(totalStepsSeconds)}',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ],
          const SizedBox(height: 24),
          _SectionTitle('Tips', color: context.textPrimary),
          const SizedBox(height: 10),
          for (final tip in method.tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: context.accentCaramel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: context.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
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
            gradient: LinearGradient(
              colors: context.isDark
                  ? [const Color(0xFF4A3428), const Color(0xFF2E1F18)]
                  : [AppColors.coffee, AppColors.espresso],
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
              Text(
                method.subtitle,
                style: TextStyle(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.containerMilk,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Zorluk: ${method.difficulty.label}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
    );
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
          color: context.cardFoam,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderLatte),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.accentCaramel, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
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
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
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
              decoration: BoxDecoration(
                color: context.accentCoffee,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: context.borderLatte),
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
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    if (step.durationSeconds != null)
                      Text(
                        fmtDuration(step.durationSeconds!),
                        style: TextStyle(
                          color: context.accentCaramel,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: context.textPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
