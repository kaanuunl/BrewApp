import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_log.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animated_entry.dart';
import '../widgets/app_header.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.logs;
    final active = state.activeTabIndex == AppState.journalTabIndex;

    final total = logs.length;
    final avgRating = total == 0
        ? 0.0
        : logs.fold<int>(0, (s, l) => s + l.rating) / total;
    final totalCoffee = logs.fold<double>(0, (s, l) => s + l.coffeeGrams);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'journal_fab',
        backgroundColor: context.accentCoffee,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: AppHeader(
                title: 'Brew Journal',
                subtitle: 'Record each brew and track your progress',
              ),
            ),
            const SizedBox(height: 16),
            if (total > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(label: 'Brews', value: '$total', emoji: '☕'),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'Avg. rating',
                      value: total == 0 ? '—' : fmtNum(avgRating),
                      emoji: '⭐',
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      label: 'Total coffee',
                      value: '${fmtNum(totalCoffee)} g',
                      emoji: '🌱',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WeeklyChart(logs: logs),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: logs.isEmpty
                  ? const _JournalEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                      itemCount: logs.length,
                      itemBuilder: (context, i) => AnimatedEntry(
                        key: ValueKey(logs[i].id),
                        index: i,
                        active: active,
                        child: _LogTile(entry: logs[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const LogFormSheet(),
    );
  }
}

class _JournalEmpty extends StatelessWidget {
  const _JournalEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.containerMilk,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 44, color: context.accentCoffee),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to record your first brew',
            style: TextStyle(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardFoam,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderLatte),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.logs});
  final List<BrewLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return d;
    });

    final counts = days.map((d) {
      return logs.where((l) {
        final ld = l.date;
        return ld.year == d.year && ld.month == d.month && ld.day == d.day;
      }).length;
    }).toList();

    final maxCount = counts.isEmpty
        ? 1
        : counts.reduce((a, b) => a > b ? a : b).clamp(1, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardFoam,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderLatte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        counts[i] > 0 ? '${counts[i]}' : '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.accentCaramel,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 70 * (counts[i] / maxCount),
                        decoration: BoxDecoration(
                          color: counts[i] > 0
                              ? context.accentCaramel
                              : context.containerMilk,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][days[i].weekday - 1],
                        style: TextStyle(
                          fontSize: 10,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});
  final BrewLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final method = BrewMethodsData.maybeByName(entry.methodName);
    final outputLabel = method?.ratioOutputLabel ?? 'Water';
    final outputUnit = method?.ratioOutputUnit ?? 'ml';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    method?.name ?? entry.methodName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: context.accentCoffee),
                  onSelected: (v) {
                    if (v == 'delete') {
                      context.read<AppState>().deleteLog(entry.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              fmtDate(entry.date),
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Grind: ${entry.grindSize}',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${fmtNum(entry.coffeeGrams)} g → ${fmtNum(entry.waterMl)} $outputUnit $outputLabel  •  ${fmtLongDuration(entry.brewTimeSeconds)}',
                  style: TextStyle(fontSize: 13, color: context.textPrimary),
                ),
                const Spacer(),
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < entry.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: i < entry.rating
                        ? context.accentCaramel
                        : context.borderLatte,
                  ),
              ],
            ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.notes,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: context.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LogFormSheet extends StatefulWidget {
  const LogFormSheet({
    super.key,
    this.prefillMethodName,
    this.prefillCoffee,
    this.prefillWater,
    this.prefillRatio,
    this.prefillTemp,
    this.prefillTimeSeconds,
  });

  final String? prefillMethodName;
  final double? prefillCoffee;
  final double? prefillWater;
  final double? prefillRatio;
  final int? prefillTemp;
  final int? prefillTimeSeconds;

  @override
  State<LogFormSheet> createState() => _LogFormSheetState();
}

class _LogFormSheetState extends State<LogFormSheet> {
  String _methodId = 'v60';
  int _rating = 5;
  late final TextEditingController _coffeeCtrl;
  late final TextEditingController _ratioCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _timeCtrl;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefillMethodName != null) {
      _methodId = BrewMethodsData.byName(widget.prefillMethodName!).id;
    }

    _coffeeCtrl = TextEditingController(
      text: widget.prefillCoffee != null ? fmtNum(widget.prefillCoffee!) : '18',
    );
    _ratioCtrl = TextEditingController(
      text: widget.prefillRatio != null ? fmtNum(widget.prefillRatio!) : '16',
    );
    _tempCtrl = TextEditingController(
      text: widget.prefillTemp != null
          ? '${widget.prefillTemp}'
          : '${BrewMethodsData.byId(_methodId).waterTempC}',
    );
    _timeCtrl = TextEditingController(
      text: widget.prefillTimeSeconds != null
          ? '${widget.prefillTimeSeconds}'
          : '180',
    );
  }

  @override
  void dispose() {
    _coffeeCtrl.dispose();
    _ratioCtrl.dispose();
    _tempCtrl.dispose();
    _timeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _coffee =>
      double.tryParse(_coffeeCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _ratio =>
      double.tryParse(_ratioCtrl.text.replaceAll(',', '.')) ?? 16;

  void _save() {
    if (_coffee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coffee amount.')),
      );
      return;
    }
    final method = BrewMethodsData.byId(_methodId);
    final appState = context.read<AppState>();
    final calibratedGrind = appState.calibratedGrindFor(method.id);
    final entry = BrewLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      methodName: method.name,
      coffeeGrams: _coffee,
      waterMl: method.outputForCoffee(_coffee),
      ratio: _ratio,
      grindSize: calibratedGrind == null
          ? method.grindSize
          : '$calibratedGrind ${appState.grinderCalibration?.unit ?? 'clicks'}',
      waterTempC: int.tryParse(_tempCtrl.text) ?? method.waterTempC,
      brewTimeSeconds: int.tryParse(_timeCtrl.text) ?? method.totalTimeSeconds,
      rating: _rating,
      notes: _notesCtrl.text.trim(),
    );
    appState.addLog(entry);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brew saved to journal! ⭐')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final method = BrewMethodsData.byId(_methodId);
    final output = method.outputForCoffee(_coffee);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'New brew entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: context.accentCoffee),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _methodId,
              decoration: const InputDecoration(labelText: 'Method'),
              items: [
                for (final m in BrewMethodsData.all)
                  DropdownMenuItem(value: m.id, child: Text(m.name)),
              ],
              onChanged: (v) {
                if (v == null) return;
                final m = BrewMethodsData.byId(v);
                setState(() {
                  _methodId = v;
                  _ratioCtrl.text = fmtNum(m.ratio);
                  _tempCtrl.text = '${m.waterTempC}';
                  _timeCtrl.text = '${m.totalTimeSeconds}';
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coffeeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Coffee (g)',
                      suffixText: 'g',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ratioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Oran',
                      suffixText: '1:X',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Temperature (°C)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Time (seconds)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Rating',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      color: i <= _rating
                          ? context.accentCaramel
                          : context.borderLatte,
                      size: 30,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Taste, body, acidity, what did you change?',
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.containerMilk,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: context.accentCoffee),
                  const SizedBox(width: 10),
                  Text(
                    '${method.ratioOutputLabel}: ',
                    style: TextStyle(color: context.accentCoffee),
                  ),
                  Text(
                    '${fmtNum(output)} ${method.ratioOutputUnit}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Add entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
