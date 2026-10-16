import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../models/coffee_recipe.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_header.dart';
import 'journal_screen.dart';

/// Adım bazlı demleme zamanlayıcı (yöntemler ve özel reçeteler destekli).
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  BrewMethod _method = BrewMethodsData.byId('v60');
  CoffeeRecipe? _recipe;

  Timer? _ticker;
  int _remaining = 180;
  int _total = 180;
  bool _running = false;
  bool _finished = false;
  int _lastStepIdx = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (state.timerSelectedMethod != null) {
      _selectMethod(state.timerSelectedMethod!);
      state.clearTimerSelection();
    } else if (state.timerSelectedRecipe != null) {
      _selectRecipe(state.timerSelectedRecipe!);
      state.clearTimerSelection();
    }
  }

  List<BrewStep> get _steps {
    if (_recipe != null) {
      final t = _recipe!.totalTimeSeconds;
      final coffee = _recipe!.coffeeGrams;
      final water = _recipe!.waterMl;

      if (t <= 45) {
        return [
          BrewStep(
            title: 'Tartım & Hazırlık',
            description: '${fmtNum(coffee)} g kahveyi tart ve yerleştir.',
            durationSeconds: 10,
          ),
          BrewStep(
            title: 'Ekstraksiyon',
            description: '${fmtNum(water)} ml kahve çıkışı.',
            durationSeconds: t > 10 ? t - 10 : t,
          ),
        ];
      } else if (t <= 180) {
        final bloomTime = 40;
        final rinseTime = 20;
        final pourTime = t > 100 ? (t - 60) ~/ 2 : 30;
        final drainTime = t - rinseTime - bloomTime - pourTime;

        return [
          const BrewStep(
            title: 'Filtreyi Islat',
            description: 'Kağıt filtreyi sıcak suyla yıka, suyu boşalt.',
            durationSeconds: 20,
          ),
          BrewStep(
            title: 'Bloom (Ön Demleme)',
            description: '${fmtNum(coffee * 2)} ml su dök, gaz çıkışını bekle.',
            durationSeconds: bloomTime,
          ),
          BrewStep(
            title: 'Ana Döküş',
            description: 'Kalan suyu dairesel hareketlerle ekle.',
            durationSeconds: pourTime > 0 ? pourTime : 30,
          ),
          BrewStep(
            title: 'Süzülme',
            description: 'Kahvenin fincana süzülmesini bekle.',
            durationSeconds: drainTime > 0 ? drainTime : 30,
          ),
        ];
      } else {
        return [
          BrewStep(
            title: 'Kahve & Su',
            description:
                '${fmtNum(coffee)} g kahveye ${fmtNum(water)} ml su ekle.',
            durationSeconds: 30,
          ),
          BrewStep(
            title: 'Demleme',
            description: 'Kahveyi demlenmeye bırak.',
            durationSeconds: t > 60 ? t - 60 : t,
          ),
          const BrewStep(
            title: 'Süzme & Servis',
            description: 'Filtrele veya pistonu yavaşça indir.',
            durationSeconds: 30,
          ),
        ];
      }
    }
    return _method.steps;
  }

  int get _stepsTotal {
    if (_recipe != null) return _recipe!.totalTimeSeconds;
    final s =
        _steps.fold<int>(0, (sum, st) => sum + (st.durationSeconds ?? 0));
    return s > 0 ? s : _method.totalTimeSeconds;
  }

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = _stepsTotal;
      _total = _stepsTotal;
      _running = false;
      _finished = false;
      _lastStepIdx = -1;
    });
  }

  void _triggerFinishHaptic() {
    HapticFeedback.heavyImpact();
    Future.delayed(
        const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
    Future.delayed(
        const Duration(milliseconds: 600), () => HapticFeedback.heavyImpact());
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    if (_finished) {
      _reset();
      return;
    }
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_remaining > 0) {
            _remaining--;

            // Adım geçişi kontrolü
            final curStep = _activeStepIndex();
            if (curStep != _lastStepIdx && curStep >= 0) {
              _lastStepIdx = curStep;
              HapticFeedback.mediumImpact();
            }

            if (_remaining == 0) {
              _running = false;
              _finished = true;
              _ticker?.cancel();
              _triggerFinishHaptic();
            }
          }
        });
      });
    }
  }

  void _addSeconds(int s) {
    HapticFeedback.lightImpact();
    setState(() {
      _remaining = (_remaining + s).clamp(0, 60 * 60 * 24);
      _total = _total > _remaining ? _total : _remaining;
    });
  }

  void _selectMethod(BrewMethod m) {
    HapticFeedback.selectionClick();
    setState(() {
      _method = m;
      _recipe = null;
    });
    _reset();
  }

  void _selectRecipe(CoffeeRecipe r) {
    HapticFeedback.selectionClick();
    setState(() {
      _recipe = r;
      // Reçetenin adına en yakın yöntemi bul
      final matching = BrewMethodsData.all.firstWhere(
        (m) => m.name == r.methodName,
        orElse: () => BrewMethodsData.byId('v60'),
      );
      _method = matching;
    });
    _reset();
  }

  int _activeStepIndex() {
    final elapsed = _total - _remaining;
    int acc = 0;
    for (int i = 0; i < _steps.length; i++) {
      final d = _steps[i].durationSeconds ?? 0;
      if (d <= 0) continue;
      if (elapsed < acc + d) return i;
      acc += d;
    }
    return _steps.isEmpty ? -1 : _steps.length - 1;
  }

  void _openSaveLogSheet() {
    final elapsed = _total - _remaining;
    final brewTime = elapsed > 0 ? elapsed : _total;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => LogFormSheet(
        prefillMethodName: _recipe?.name ?? _method.name,
        prefillCoffee: _recipe?.coffeeGrams ?? _method.defaultCoffeeGrams,
        prefillRatio: _recipe?.ratio ?? _method.ratio,
        prefillTemp: _recipe?.waterTempC ?? _method.waterTempC,
        prefillTimeSeconds: brewTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final userRecipes = state.recipes;

    final progress = _total == 0 ? 0.0 : 1 - (_remaining / _total);
    final activeIdx = _activeStepIndex();

    final title = _recipe != null ? _recipe!.name : _method.name;
    final subtitle = _recipe != null
        ? '${_recipe!.methodName} • ${fmtNum(_recipe!.coffeeGrams)}g / ${fmtNum(_recipe!.waterMl)}ml'
        : '${_method.subtitle} • ${_method.waterTempC}°C';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const AppHeader(
              title: 'Demleme Zamanlayıcı',
              subtitle: 'Adım adım kılavuz ve geri sayım',
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: 16),

            // Seçim Çipleri (Standart Yöntemler + Özel Reçeteler)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final m in BrewMethodsData.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m.name),
                        selected: _recipe == null && _method.id == m.id,
                        onSelected: (_) => _selectMethod(m),
                        selectedColor: context.accentCoffee,
                        labelStyle: TextStyle(
                          color: (_recipe == null && _method.id == m.id)
                              ? Colors.white
                              : context.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (userRecipes.isNotEmpty) ...[
                    Container(
                      height: 20,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: context.borderLatte,
                    ),
                    for (final r in userRecipes)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            Icons.bookmark,
                            size: 16,
                            color: _recipe?.id == r.id
                                ? Colors.white
                                : context.accentCaramel,
                          ),
                          label: Text(r.name),
                          selected: _recipe?.id == r.id,
                          onSelected: (_) => _selectRecipe(r),
                          selectedColor: context.accentCaramel,
                          labelStyle: TextStyle(
                            color: _recipe?.id == r.id
                                ? Colors.white
                                : context.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Aktif Bilgi Kartı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: context.containerMilk,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _recipe != null ? Icons.bookmark : _method.icon,
                    color: context.accentCoffee,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_recipe != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.accentCaramel.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reçete',
                        style: TextStyle(
                          color: context.accentCaramel,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dairesel Zamanlayıcı
            Center(
              child: _CircularTimer(
                progress: progress,
                remainingText: fmtLongDuration(_remaining),
                finished: _finished,
              ),
            ),
            const SizedBox(height: 24),

            // Kontrol Düğmeleri
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundBtn(
                    icon: Icons.refresh,
                    tooltip: 'Sıfırla',
                    onTap: _reset,
                  ),
                  const SizedBox(width: 20),
                  _RoundBtn(
                    icon: _running ? Icons.pause : Icons.play_arrow,
                    tooltip: _running ? 'Durdur' : 'Başlat',
                    primary: true,
                    onTap: _toggle,
                  ),
                  const SizedBox(width: 20),
                  _RoundBtn(
                    icon: Icons.add,
                    tooltip: '+30 sn',
                    onTap: () => _addSeconds(30),
                  ),
                ],
              ),
            ),

            // Tamamlanma Kutlaması ve Günlüğe Kaydet Butonu
            if (_finished) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.statusSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.statusSuccess.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('☕', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demleme Tamamlandı!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                'Bu demlemenin sonucunu ve puanını kaydet.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _openSaveLogSheet,
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Demlemeyi Günlüğe Kaydet'),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.statusSuccess,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adımlar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                if (_running || _finished)
                  TextButton.icon(
                    onPressed: _openSaveLogSheet,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('Günlüğe Ekle'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.accentCoffee,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _steps.length; i++)
              _TimerStepTile(
                step: _steps[i],
                index: i,
                active: i == activeIdx && _running,
                done: _finished || (_running && i < activeIdx),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircularTimer extends StatelessWidget {
  const _CircularTimer({
    required this.progress,
    required this.remainingText,
    required this.finished,
  });
  final double progress;
  final String remainingText;
  final bool finished;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              backgroundColor: context.containerMilk,
              valueColor: AlwaysStoppedAnimation<Color>(
                finished ? context.statusSuccess : context.accentCaramel,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (finished)
                const Text('☕', style: TextStyle(fontSize: 44))
              else
                Text(
                  remainingText,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                finished ? 'Demleme tamam!' : 'kalan süre',
                style: TextStyle(fontSize: 14, color: context.accentCoffee),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.primary = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: primary ? context.accentCoffee : context.containerMilk,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 30,
              color: primary ? Colors.white : context.accentCoffee,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerStepTile extends StatelessWidget {
  const _TimerStepTile({
    required this.step,
    required this.index,
    required this.active,
    required this.done,
  });
  final BrewStep step;
  final int index;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final Color ringColor = active
        ? context.accentCaramel
        : done
            ? context.statusSuccess
            : context.borderLatte;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: active ? context.containerMilk : context.cardFoam,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? context.accentCaramel : context.borderLatte,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ringColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: active
                        ? context.textPrimary
                        : context.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (step.durationSeconds != null)
            Text(
              fmtDuration(step.durationSeconds!),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: active ? context.accentCaramel : context.accentCoffee,
              ),
            ),
        ],
      ),
    );
  }
}
