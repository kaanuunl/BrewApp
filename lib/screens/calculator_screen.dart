import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../models/grinder_calibration.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import 'grinder_calibration_screen.dart';
import 'coffee_guide_screen.dart';
import 'grind_guide_screen.dart';
import 'recipes_screen.dart';

enum _CalcMode { coffeeToWater, waterToCoffee }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  _CalcMode _mode = _CalcMode.coffeeToWater;
  double _ratio = 16.0;
  String? _selectedPresetId = 'v60';

  final _coffeeCtrl = TextEditingController(text: '18');
  final _waterCtrl = TextEditingController(text: '288');

  static const cups = 250.0;

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

  void _selectBrewPreset(BrewMethod method) {
    setState(() {
      _selectedPresetId = method.id;
      _ratio = method.ratio;
      _coffeeCtrl.text = fmtNum(method.defaultCoffeeGrams);
    });
    _recalc();
  }

  void _saveAsRecipe(double coffee, double ratio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          RecipeFormSheet(initialCoffee: coffee, initialRatio: ratio),
    );
  }

  void _openInTimer(double coffee, double ratio) {
    final matching = BrewMethodsData.all.firstWhere(
      (m) => (m.ratio - ratio).abs() < 0.5,
      orElse: () => BrewMethodsData.byId('v60'),
    );
    context.read<AppState>().startTimerWithMethod(matching);
  }

  @override
  Widget build(BuildContext context) {
    final calibration = context.watch<AppState>().grinderCalibration;
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
              title: 'Coffee Ratio Calculator',
              subtitle: 'Measure coffee and water by ratio',
              icon: Icons.calculate_outlined,
            ),
            const SizedBox(height: 14),
            _CalibrationShortcut(calibration: calibration),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _LearnShortcut(
                    icon: Icons.coffee_outlined,
                    title: 'Coffee guide',
                    subtitle: 'Capsules, whole beans, and ground coffee',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CoffeeGuideScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LearnShortcut(
                    icon: Icons.grain_outlined,
                    title: 'Grind guide',
                    subtitle: 'Settings by brewing method',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const GrindGuideScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculation direction',
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
                        label: Text('Coffee → Water'),
                        icon: Icon(Icons.coffee_outlined),
                      ),
                      ButtonSegment(
                        value: _CalcMode.waterToCoffee,
                        label: Text('Water → Coffee'),
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
                        'Ratio — ${fmtRatio(_ratio)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                      ),
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
                          '1 g coffee : ${_ratio.toStringAsFixed(1)} g water',
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
                      setState(() {
                        _ratio = v;
                        _selectedPresetId = null;
                      });
                      _recalc();
                    },
                  ),
                  Text(
                    'Popular starting ratios',
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
                    children: BrewMethodsData.popular
                        .map(
                          (method) => _RatioChip(
                            label:
                                '${method.name} (${fmtRatio(method.ratio)})',
                            selected: _selectedPresetId == method.id,
                            onTap: () => _selectBrewPreset(method),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    child: _selectedPresetId == null
                        ? const Text('Custom ratio • adjust to taste')
                        : _PresetDetails(
                            key: ValueKey(_selectedPresetId),
                            method: BrewMethodsData.byId(_selectedPresetId!),
                          ),
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
                    coffeeToWater ? 'Coffee amount (g)' : 'Water amount (ml)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: coffeeToWater ? _coffeeCtrl : _waterCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
              primaryLabel: coffeeToWater ? 'Water needed' : 'Coffee needed',
              primaryValue: coffeeToWater ? water : coffee,
              primaryUnit: coffeeToWater ? 'ml' : 'g',
              secondaryLabel: coffeeToWater ? 'Coffee' : 'Water',
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

class _CalibrationShortcut extends StatelessWidget {
  const _CalibrationShortcut({required this.calibration});

  final GrinderCalibration? calibration;

  @override
  Widget build(BuildContext context) {
    final espressoSetting = calibration?.settingFor('espresso');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const GrinderCalibrationScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.accentCoffee.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.tune, color: context.accentCoffee),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grinder calibration',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      espressoSetting == null
                          ? 'Save settings for espresso and other methods'
                          : 'Espresso: $espressoSetting ${calibration?.unit ?? ''}',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.accentCoffee),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnShortcut extends StatelessWidget {
  const _LearnShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: context.accentCoffee, size: 22),
              const SizedBox(height: 9),
              Text(
                title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: context.textSecondary, fontSize: 11),
              ),
            ],
          ),
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

class _PresetDetails extends StatelessWidget {
  const _PresetDetails({super.key, required this.method});

  final BrewMethod method;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calibratedGrind = appState.calibratedGrindFor(method.id);
    final calibration = appState.grinderCalibration;
    final grind = calibratedGrind == null
        ? method.grindSize
        : '$calibratedGrind ${calibration?.unit ?? 'clicks'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.containerMilk.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _PresetValue(
            icon: Icons.scale_outlined,
            label: '${fmtNum(method.defaultCoffeeGrams)} g coffee',
          ),
          _PresetValue(
            icon: Icons.water_drop_outlined,
            label:
                '${fmtNum(method.outputForCoffee(method.defaultCoffeeGrams))} ${method.ratioOutputUnit}',
          ),
          _PresetValue(
            icon: Icons.thermostat_outlined,
            label: '${method.waterTempC}°C',
          ),
          _PresetValue(icon: Icons.grain_outlined, label: grind),
          _PresetValue(
            icon: Icons.timer_outlined,
            label: fmtLongDuration(method.totalTimeSeconds),
          ),
        ],
      ),
    );
  }
}

class _PresetValue extends StatelessWidget {
  const _PresetValue({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: context.accentCoffee),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
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
                label: 'Approx.',
                value: '${fmtNum(cupCount)} cups',
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
                  label: const Text('Create recipe'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
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
                  label: const Text('Timer'),
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
