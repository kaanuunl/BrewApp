import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

enum _CalcMode { coffeeToWater, waterToCoffee }

/// Kahve-su gramaj hesaplayıcı.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  _CalcMode _mode = _CalcMode.coffeeToWater;
  double _ratio = 16.0;

  final _coffeeCtrl = TextEditingController(text: '18');
  final _waterCtrl = TextEditingController(text: '300');

  static const cups = 250.0; // 1 fincan ≈ 250 ml su

  @override
  void dispose() {
    _coffeeCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  double get _coffee {
    final v = double.tryParse(_coffeeCtrl.text.replaceAll(',', '.'));
    return (v ?? 0).clamp(0, 5000).toDouble();
  }

  double get _water {
    final v = double.tryParse(_waterCtrl.text.replaceAll(',', '.'));
    return (v ?? 0).clamp(0, 50000).toDouble();
  }

  void _recalc() {
    setState(() {
      if (_mode == _CalcMode.coffeeToWater) {
        _waterCtrl.text = fmtNum(_coffee * _ratio);
      } else {
        _coffeeCtrl.text = fmtNum(_water / _ratio);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final coffeeToWater = _mode == _CalcMode.coffeeToWater;
    final coffee = coffeeToWater ? _coffee : _water / _ratio;
    final water = coffeeToWater ? _coffee * _ratio : _water;
    final cupCount = water / cups;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _Header(),
            const SizedBox(height: 20),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hesaplama yönü',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  SegmentedButton<_CalcMode>(
                    segments: const [
                      ButtonSegment(
                        value: _CalcMode.coffeeToWater,
                        label: Text('Kahve → Su'),
                        icon: Icon(Icons.coffee_outlined),
                      ),
                      ButtonSegment(
                        value: _CalcMode.waterToCoffee,
                        label: Text('Su → Kahve'),
                        icon: Icon(Icons.water_drop_outlined),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Oran — ${fmtRatio(_ratio)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 8),
                  Slider(
                    value: _ratio,
                    min: 8,
                    max: 20,
                    divisions: 24,
                    label: fmtRatio(_ratio),
                    onChanged: (v) {
                      setState(() => _ratio = v);
                      _recalc();
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in [12.0, 15.0, 16.0, 17.0, 18.0])
                        _RatioChip(
                          label: fmtRatio(r),
                          selected: _ratio == r,
                          onTap: () {
                            setState(() => _ratio = r);
                            _recalc();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coffeeToWater ? 'Kahve miktarı (g)'
                          : 'Su miktarı (ml)',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: coffeeToWater ? _coffeeCtrl : _waterCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espresso),
                    decoration: InputDecoration(
                      suffixText: coffeeToWater ? 'g' : 'ml',
                      suffixStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.coffee),
                    ),
                    onChanged: (_) => _recalc(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              primaryLabel: coffeeToWater ? 'Su miktarı' : 'Kahve miktarı',
              primaryValue: coffeeToWater ? water : coffee,
              primaryUnit: coffeeToWater ? 'ml' : 'g',
              secondaryLabel: coffeeToWater ? 'Kahve' : 'Su',
              secondaryValue: coffeeToWater ? coffee : water,
              secondaryUnit: coffeeToWater ? 'g' : 'ml',
              cupCount: cupCount,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.milk,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calculate,
                  color: AppColors.coffee, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gramaj Hesaplayıcı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                  Text('Kahve-su oranına göre doğru ölçü',
                      style: TextStyle(color: AppColors.coffee)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _RatioChip extends StatelessWidget {
  const _RatioChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.coffee : AppColors.milk,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.espresso,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.primaryLabel,
    required this.primaryValue,
    required this.primaryUnit,
    required this.secondaryLabel,
    required this.secondaryValue,
    required this.secondaryUnit,
    required this.cupCount,
  });

  final String primaryLabel;
  final double primaryValue;
  final String primaryUnit;
  final String secondaryLabel;
  final double secondaryValue;
  final String secondaryUnit;
  final double cupCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.coffee, AppColors.espresso],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            primaryLabel,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtNum(primaryValue),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  primaryUnit,
                  style: const TextStyle(
                      color: AppColors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(
                label: secondaryLabel,
                value: '${fmtNum(secondaryValue)} $secondaryUnit',
                emoji: '☕',
              ),
              const SizedBox(width: 12),
              _MiniStat(
                label: 'Yaklaşık',
                value: '${fmtNum(cupCount)} fincan',
                emoji: '🥤',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.emoji,
  });
  final String label;
  final String value;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
