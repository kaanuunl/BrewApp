import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../models/grinder_calibration.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/grinder_dial.dart';

class GrinderCalibrationScreen extends StatefulWidget {
  const GrinderCalibrationScreen({super.key});

  @override
  State<GrinderCalibrationScreen> createState() =>
      _GrinderCalibrationScreenState();
}

class _GrinderCalibrationScreenState extends State<GrinderCalibrationScreen> {
  late final TextEditingController _grinderCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _stepCtrl;
  late final Map<String, TextEditingController> _settingCtrls;
  String _selectedMethodId = BrewMethodsData.calibrationPriority.first.id;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final calibration = context.read<AppState>().grinderCalibration;
    _grinderCtrl = TextEditingController(
      text: calibration?.grinderName ?? '',
    );
    _unitCtrl = TextEditingController(text: calibration?.unit ?? 'clicks');
    _stepCtrl = TextEditingController(text: '1');
    _settingCtrls = {
      for (final method in BrewMethodsData.calibrationPriority)
        method.id: TextEditingController(
          text: calibration?.settingFor(method.id) ?? '',
        ),
    };
  }

  @override
  void dispose() {
    _grinderCtrl.dispose();
    _unitCtrl.dispose();
    _stepCtrl.dispose();
    for (final controller in _settingCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _grinderCtrl.text.trim();
    final unit = _unitCtrl.text.trim();
    final settings = {
      for (final entry in _settingCtrls.entries)
        if (entry.value.text.trim().isNotEmpty)
          entry.key: entry.value.text.trim(),
    };

    if (name.isEmpty || unit.isEmpty || settings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a grinder, a setting unit, and at least one method setting.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<AppState>().saveGrinderCalibration(
            GrinderCalibration(
              grinderName: name,
              unit: unit,
              settings: settings,
              updatedAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grinder profile saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save grinder profile: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clear() async {
    try {
      await context.read<AppState>().clearGrinderCalibration();
      if (!mounted) return;
      _grinderCtrl.clear();
      _unitCtrl.text = 'clicks';
      for (final controller in _settingCtrls.values) {
        controller.clear();
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grinder profile deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete grinder profile: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calibration = context.watch<AppState>().grinderCalibration;
    final calibrationMethods = BrewMethodsData.calibrationPriority;
    final popularCount = BrewMethodsData.popular.length + 1;
    final selectedMethod = BrewMethodsData.byId(_selectedMethodId);
    final selectedSettingCtrl = _settingCtrls[_selectedMethodId]!;
    final selectedValue = double.tryParse(
      selectedSettingCtrl.text.trim().replaceAll(',', '.'),
    );
    final step = double.tryParse(_stepCtrl.text.trim().replaceAll(',', '.'));
    final stepIsValid = step != null && step > 0;
    final validStep = step != null && step > 0 ? step : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Grinder calibration')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderLatte),
            ),
            child: Text(
              'Grinder clicks and dial values cannot be compared across brands and are often non-linear. Save the settings you test for each method on your grinder; the app does not control the grinder.',
              style: TextStyle(
                color: context.textPrimary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _grinderCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Grinder brand / model',
              hintText: 'For example, your grinder model',
              prefixIcon: Icon(Icons.tune),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _unitCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Setting unit',
              hintText: 'Clicks, steps, turns, or dial value',
              prefixIcon: Icon(Icons.straighten),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tested settings by method',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Review these alongside tasting notes in your brew journal. For a sour or weak cup, try a slightly finer setting; for a bitter or drying cup, try a coarser setting. Change only one variable per trial.',
            style: TextStyle(
              color: context.textSecondary,
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Espresso and common filter/immersion methods are shown first; other profiles follow below.',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedMethodId,
            decoration: const InputDecoration(
              labelText: 'Method to adjust with the dial',
              prefixIcon: Icon(Icons.tune),
            ),
            items: [
              for (final method in calibrationMethods)
                DropdownMenuItem(value: method.id, child: Text(method.name)),
            ],
            onChanged: (id) {
              if (id != null) setState(() => _selectedMethodId = id);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: selectedSettingCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: '${selectedMethod.name} setting',
              hintText: _startingPoint(selectedMethod),
              suffixText: _unitCtrl.text.trim().isEmpty
                  ? null
                  : _unitCtrl.text.trim(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Small adjustment step',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 112,
                child: TextField(
                  controller: _stepCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '1',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Drag the dial or use + / − to adjust. Increasing the number may not make your grinder finer.',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          GrinderDial(
            value: selectedValue ?? 0,
            unit: _unitCtrl.text.trim().isEmpty ? 'setting' : _unitCtrl.text.trim(),
            step: validStep,
            enabled: selectedValue != null && stepIsValid,
            onChanged: (value) {
              selectedSettingCtrl.text = _formatSetting(value);
              setState(() {});
            },
          ),
          if (selectedValue == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Enter a numeric setting above to enable the dial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            ),
          if (!stepIsValid)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'The dial step must be a number greater than zero.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 8),
          for (var index = 0; index < calibrationMethods.length; index++)
            Builder(
              builder: (context) {
                final method = calibrationMethods[index];
                final popular = index < popularCount;
                if (method.id == _selectedMethodId) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _settingCtrls[method.id],
                    decoration: InputDecoration(
                      labelText: method.name,
                      hintText: _startingPoint(method),
                      helperText: popular
                          ? 'Popular profile • calibrate by tasting on your grinder'
                          : null,
                      suffixText: _unitCtrl.text.trim().isEmpty
                          ? null
                          : _unitCtrl.text.trim(),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save calibration'),
          ),
          if (calibration != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : _clear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete grinder profile'),
            ),
          ],
        ],
      ),
    );
  }

  String _startingPoint(BrewMethod method) {
    if (method.id == 'espresso') {
      return 'Fine; adjust to basket and flow time';
    }
    if (method.id == 'turkish') return 'Extra fine / powder';
    if (const {'frenchpress', 'coldbrew', 'colddrip'}.contains(method.id)) {
      return 'Coarse; adjust to time and flow';
    }
    if (const {'moka', 'phin', 'aeropress'}.contains(method.id)) {
      return 'Medium-fine; adjust to flow';
    }
    return 'Medium / medium-fine; adjust to filter';
  }

  String _formatSetting(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}
