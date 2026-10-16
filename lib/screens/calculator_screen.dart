import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import 'recipes_screen.dart';

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
  final _waterCtrl = TextEditingController(text: '288');

  static const cups = 250.0; // 1 fincan ≈ 250 ml su

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (state.calcRatio != null) {
      _ratio = state.calcRatio!;
      if (state.calcCoffee != null) {
        _coffeeCtrl.text = fmtNum(state.calcCoffee!);
      }
      _recalc();
      state.clearCalculatorOverrides();
    }
  }

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

  void _saveAsRecipe(double coffee, double ratio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecipeFormSheet(
        initialCoffee: coffee,
        initialRatio: ratio,
      ),
    );
  }

  void _openInTimer(double coffee, double ratio) {
    // Orana en yakın yöntemi bul
    final matching = BrewMethodsData.all.firstWhere(
      (m) => (m.ratio - ratio).abs() < 0.5,
      orElse: () => BrewMethodsData.byId('v60'),
    );
    context.read<AppState>().startTimerWithMethod(matching);
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
            const AppHeader(
              title: 'Gramaj Hesaplayıcı',
              subtitle: 'Kahve-su oranına göre doğru ölçü',
              icon: Icons.calculate_outlined,
            ),
            const SizedBox(height: 20),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hesaplama yönü',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.textPrimary,
                    ),
                  ),
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
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Oran — ${fmtRatio(_ratio)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.containerMilk,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '1g kahve : ${_ratio.toStringAsFixed(1)}g su',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: context.accentCoffee,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _ratio.clamp(2.0, 20.0),
                    min: 2,
                    max: 20,
                    divisions: 36,
                    label: fmtRatio(_ratio),
                    activeColor: context.accentCaramel,
                    onChanged: (v) {
                      setState(() => _ratio = v);
                      _recalc();
                    },
                  ),
                  Text(
                    'Popüler Yöntemler & Oranlar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _RatioChip(
                        label: 'Espresso (1:2)',
                        selected: _ratio == 2.0,
                        onTap: () {
                          setState(() => _ratio = 2.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'Cold Brew (1:6)',
                        selected: _ratio == 6.0,
                        onTap: () {
                          setState(() => _ratio = 6.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'Moka Pot (1:8)',
                        selected: _ratio == 8.0,
                        onTap: () {
                          setState(() => _ratio = 8.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'AeroPress (1:13)',
                        selected: _ratio == 13.0,
                        onTap: () {
                          setState(() => _ratio = 13.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'Chemex (1:15)',
                        selected: _ratio == 15.0,
                        onTap: () {
                          setState(() => _ratio = 15.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'V60 (1:16)',
                        selected: _ratio == 16.0,
                        onTap: () {
                          setState(() => _ratio = 16.0);
                          _recalc();
                        },
                      ),
                      _RatioChip(
                        label: 'Hafif Filtre (1:18)',
                        selected: _ratio == 18.0,
                        onTap: () {
                          setState(() => _ratio = 18.0);
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
                  Text(
                    coffeeToWater ? 'Kahve miktarı (g)' : 'Su miktarı (ml)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: coffeeToWater ? _coffeeCtrl : _waterCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      suffixText: coffeeToWater ? 'g' : 'ml',
                      suffixStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.accentCoffee,
                      ),
                    ),
                    onChanged: (_) => _recalc(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ResultCard(
              primaryLabel: coffeeToWater ? 'Gereken su' : 'Gereken kahve',
              primaryValue: coffeeToWater ? water : coffee,
              primaryUnit: coffeeToWater ? 'ml' : 'g',
              secondaryLabel: coffeeToWater ? 'Kahve' : 'Su',
              secondaryValue: coffeeToWater ? coffee : water,
              secondaryUnit: coffeeToWater ? 'g' : 'ml',
              cupCount: cupCount,
              onSaveRecipe: () => _saveAsRecipe(coffee, _ratio),
              onOpenTimer: () => _openInTimer(coffee, _ratio),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? context.accentCoffee : context.containerMilk,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
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
    required this.onSaveRecipe,
    required this.onOpenTimer,
  });

  final String primaryLabel;
  final double primaryValue;
  final String primaryUnit;
  final String secondaryLabel;
  final double secondaryValue;
  final String secondaryUnit;
  final double cupCount;
  final VoidCallback onSaveRecipe;
  final VoidCallback onOpenTimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDark
              ? [const Color(0xFF38261C), const Color(0xFF221712)]
              : [AppColors.coffee, AppColors.espresso],
        ),
        borderRadius: BorderRadius.circular(24),
        border: context.isDark
            ? Border.all(color: context.borderLatte, width: 1.2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            primaryLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtNum(primaryValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  primaryUnit,
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
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
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveRecipe,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Reçete Yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenTimer,
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: const Text('Zamanlayıcı'),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.accentCaramel,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
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
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
