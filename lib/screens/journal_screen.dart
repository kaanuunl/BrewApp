import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_log.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Demleme günlüğü: kayıtlar, istatistikler ve son 7 gün grafiği.
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final logs = state.logs;

    final total = logs.length;
    final avgRating =
        total == 0 ? 0.0 : logs.fold<int>(0, (s, l) => s + l.rating) / total;
    final totalCoffee = logs.fold<double>(0, (s, l) => s + l.coffeeGrams);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coffee,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demleme Günlüğü',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                  const SizedBox(height: 4),
                  Text('Her demlemeyi kaydet, gelişimini izle',
                      style: TextStyle(color: AppColors.coffee)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (total > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(label: 'Demleme', value: '$total', emoji: '☕'),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Ort. puan',
                        value: total == 0 ? '—' : fmtNum(avgRating),
                        emoji: '⭐'),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Toplam kahve',
                        value: '${fmtNum(totalCoffee)} g',
                        emoji: '🌱'),
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
                      itemBuilder: (context, i) => _LogTile(entry: logs[i]),
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
      backgroundColor: AppColors.cream,
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
              color: AppColors.milk,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history,
                size: 44, color: AppColors.coffee),
          ),
          const SizedBox(height: 16),
          const Text('Henüz kayıt yok',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso)),
          const SizedBox(height: 6),
          Text('İlk demlemeni kaydetmek için + butonuna bas',
              style: TextStyle(color: AppColors.coffee)),
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
          color: AppColors.foam,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.latte),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espresso)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.coffee)),
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
      final d = DateTime(now.year, now.month, now.day).subtract(
          Duration(days: 6 - i));
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
        color: AppColors.foam,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.latte),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Son 7 gün',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.espresso)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(counts[i] > 0 ? '${counts[i]}' : '',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.caramel)),
                      const SizedBox(height: 4),
                      Container(
                        height: 70 * (counts[i] / maxCount),
                        decoration: BoxDecoration(
                          color: counts[i] > 0
                              ? AppColors.caramel
                              : AppColors.milk,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                            [days[i].weekday - 1],
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.coffee),
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
                  child: Text(entry.methodName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.coffee),
                  onSelected: (v) {
                    if (v == 'delete') {
                      context.read<AppState>().deleteLog(entry.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'delete', child: Text('Sil')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(fmtDate(entry.date),
                style: TextStyle(color: AppColors.coffee, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${fmtNum(entry.coffeeGrams)} g → ${fmtNum(entry.waterMl)} ml',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.espresso),
                ),
                const Spacer(),
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < entry.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: i < entry.rating
                        ? AppColors.caramel
                        : AppColors.latte,
                  ),
              ],
            ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.notes,
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: AppColors.espresso.withValues(alpha: 0.75))),
            ],
          ],
        ),
      ),
    );
  }
}

/// Yeni günlük kaydı ekleme formu.
class LogFormSheet extends StatefulWidget {
  const LogFormSheet({super.key});

  @override
  State<LogFormSheet> createState() => _LogFormSheetState();
}

class _LogFormSheetState extends State<LogFormSheet> {
  String _methodId = BrewMethodsData.all.first.id;
  int _rating = 4;
  final _coffeeCtrl = TextEditingController(text: '18');
  final _ratioCtrl = TextEditingController(text: '16');
  final _tempCtrl = TextEditingController(text: '93');
  final _timeCtrl = TextEditingController(text: '180');
  final _notesCtrl = TextEditingController();

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kahve miktarı geçerli değil.')));
      return;
    }
    final method = BrewMethodsData.byId(_methodId);
    final entry = BrewLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      methodName: method.name,
      coffeeGrams: _coffee,
      waterMl: _coffee * _ratio,
      ratio: _ratio,
      grindSize: method.grindSize,
      waterTempC: int.tryParse(_tempCtrl.text) ?? method.waterTempC,
      brewTimeSeconds: int.tryParse(_timeCtrl.text) ?? method.totalTimeSeconds,
      rating: _rating,
      notes: _notesCtrl.text.trim(),
    );
    context.read<AppState>().addLog(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final water = _coffee * _ratio;

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
                const Expanded(
                  child: Text('Yeni Demleme Kaydı',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.coffee),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _methodId,
              decoration: const InputDecoration(labelText: 'Yöntem'),
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
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Kahve (g)', suffixText: 'g'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _ratioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Oran', suffixText: '1:X'),
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
                    decoration:
                        const InputDecoration(labelText: 'Sıcaklık (°C)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Süre (sn)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Puan',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.espresso)),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(() => _rating = i),
                    icon: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      color: i <= _rating ? AppColors.caramel : AppColors.latte,
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
                  labelText: 'Notlar (opsiyonel)',
                  hintText: 'Tat, kıvam, neyi değiştirdin?'),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.milk,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.coffee),
                  const SizedBox(width: 10),
                  Text('Su: ', style: TextStyle(color: AppColors.coffee)),
                  Text('${fmtNum(water)} ml',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Kaydı Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
