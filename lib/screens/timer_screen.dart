import 'dart:async';

import 'package:flutter/material.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Adım bazlı demleme zamanlayıcı.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  BrewMethod _method = BrewMethodsData.byId('v60');
  Timer? _ticker;
  int _remaining = 180;
  int _total = 180;
  bool _running = false;
  bool _finished = false;

  List<BrewStep> get _steps => _method.steps;

  int get _stepsTotal {
    final s = _steps.fold<int>(0, (sum, st) => sum + (st.durationSeconds ?? 0));
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
    });
  }

  void _toggle() {
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
            if (_remaining == 0) {
              _running = false;
              _finished = true;
              _ticker?.cancel();
            }
          }
        });
      });
    }
  }

  void _addSeconds(int s) {
    setState(() {
      _remaining = (_remaining + s).clamp(0, 60 * 60 * 24);
      _total = _total > _remaining ? _total : _remaining;
    });
  }

  void _selectMethod(BrewMethod m) {
    setState(() => _method = m);
    _reset();
  }

  /// Şu an üzerinde bulunulan adımın indeksi (elapsed -> step).
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

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? 0.0 : 1 - (_remaining / _total);
    final activeIdx = _activeStepIndex();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text('Demleme Zamanlayıcı',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800, color: AppColors.espresso)),
            const SizedBox(height: 4),
            Text('Yöntemi seç, adımları takip et',
                style: TextStyle(color: AppColors.coffee)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final m in BrewMethodsData.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m.name),
                        selected: _method.id == m.id,
                        onSelected: (_) => _selectMethod(m),
                        selectedColor: AppColors.coffee,
                        labelStyle: TextStyle(
                          color: _method.id == m.id
                              ? Colors.white
                              : AppColors.espresso,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _CircularTimer(
                progress: progress,
                remainingText: fmtLongDuration(_remaining),
                finished: _finished,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundBtn(
                    icon: Icons.exposure,
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
            const SizedBox(height: 28),
            Text('Adımlar',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espresso)),
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
              backgroundColor: AppColors.milk,
              valueColor: AlwaysStoppedAnimation<Color>(
                  finished ? AppColors.success : AppColors.caramel),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (finished)
                const Text('☕',
                    style: TextStyle(fontSize: 40))
              else
                Text(
                  remainingText,
                  style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.espresso,
                      height: 1),
                ),
              const SizedBox(height: 6),
              Text(
                finished ? 'Demleme tamam!' : 'kalan süre',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.coffee),
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
        color: primary ? AppColors.coffee : AppColors.milk,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(icon,
                size: 30,
                color: primary ? Colors.white : AppColors.coffee),
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
        ? AppColors.caramel
        : done
            ? AppColors.success
            : AppColors.latte;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.milk : AppColors.foam,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: active ? AppColors.caramel : AppColors.latte, width: 1.2),
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
                : Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: active
                            ? AppColors.espresso
                            : AppColors.espresso.withValues(alpha: 0.7))),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(step.description,
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.coffee.withValues(alpha: 0.9))),
                ],
              ],
            ),
          ),
          if (step.durationSeconds != null)
            Text(fmtDuration(step.durationSeconds!),
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: active ? AppColors.caramel : AppColors.coffee)),
        ],
      ),
    );
  }
}
