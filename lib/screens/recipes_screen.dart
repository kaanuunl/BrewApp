import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/coffee_recipe.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Kullanıcının kaydettiği özel reçeteler.
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recipes = state.recipes;

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
                  Text('Reçetelerim',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                  const SizedBox(height: 4),
                  Text(
                    recipes.isEmpty
                        ? 'Henüz reçete yok. + ile yeni bir reçete ekle.'
                        : '${recipes.length} kayıtlı reçete',
                    style: TextStyle(color: AppColors.coffee),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: recipes.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      itemCount: recipes.length,
                      itemBuilder: (context, i) =>
                          _RecipeCard(recipe: recipes[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {CoffeeRecipe? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecipeFormSheet(existing: existing),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            child: const Icon(Icons.bookmark_border,
                size: 44, color: AppColors.coffee),
          ),
          const SizedBox(height: 16),
          const Text('Reçeten yok',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.espresso)),
          const SizedBox(height: 6),
          Text('Özel kahve tariflerini buradan kaydet',
              style: TextStyle(color: AppColors.coffee)),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});
  final CoffeeRecipe recipe;

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
                  child: Text(recipe.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.coffee),
                  onSelected: (v) {
                    if (v == 'edit') {
                      RecetasScreenBridge.openForm(context, recipe);
                    } else if (v == 'delete') {
                      context
                          .read<AppState>()
                          .deleteRecipe(recipe.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                    PopupMenuItem(value: 'delete', child: Text('Sil')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(recipe.methodName,
                style: TextStyle(color: AppColors.coffee, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _Pill(bg: AppColors.milk, value: '${fmtNum(recipe.coffeeGrams)} g kahve'),
                const SizedBox(width: 8),
                _Pill(bg: AppColors.milk, value: '${fmtNum(recipe.waterMl)} ml su'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Pill(bg: AppColors.caramel.withValues(alpha: 0.15), value: fmtRatio(recipe.ratio)),
                const SizedBox(width: 8),
                _Pill(bg: AppColors.caramel.withValues(alpha: 0.15), value: '${recipe.waterTempC}°C'),
              ],
            ),
            if (recipe.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(recipe.notes,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.espresso.withValues(alpha: 0.8))),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.bg, required this.value});
  final Color bg;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(value,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.espresso)),
    );
  }
}

/// Yeni reçete eklemek / düzenlemek için form.
class RecipeFormSheet extends StatefulWidget {
  const RecipeFormSheet({super.key, this.existing});
  final CoffeeRecipe? existing;

  @override
  State<RecipeFormSheet> createState() => _RecipeFormSheetState();
}

class _RecipeFormSheetState extends State<RecipeFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _coffeeCtrl;
  late final TextEditingController _ratioCtrl;
  late final TextEditingController _tempCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _notesCtrl;
  String _methodId = BrewMethodsData.all.first.id;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _coffeeCtrl = TextEditingController(
        text: e != null ? fmtNum(e.coffeeGrams) : '18');
    _ratioCtrl =
        TextEditingController(text: e != null ? fmtNum(e.ratio) : '16');
    _tempCtrl =
        TextEditingController(text: e != null ? '${e.waterTempC}' : '93');
    _timeCtrl = TextEditingController(
        text: e != null ? '${e.totalTimeSeconds}' : '180');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      _methodId = BrewMethodsData.all.any((m) => m.name == e.methodName)
          ? BrewMethodsData.all.firstWhere((m) => m.name == e.methodName).id
          : BrewMethodsData.all.first.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _coffee <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lütfen bir isim ve geçerli kahve miktarı gir.')));
      return;
    }
    final method = BrewMethodsData.byId(_methodId);
    final recipe = CoffeeRecipe(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      methodName: method.name,
      coffeeGrams: _coffee,
      waterMl: _coffee * _ratio,
      ratio: _ratio,
      grindSize: method.grindSize,
      waterTempC: int.tryParse(_tempCtrl.text) ?? method.waterTempC,
      totalTimeSeconds: int.tryParse(_timeCtrl.text) ?? method.totalTimeSeconds,
      notes: _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    final state = context.read<AppState>();
    if (_isEdit) {
      state.updateRecipe(recipe);
    } else {
      state.addRecipe(recipe);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final coffee = _coffee;
    final ratio = _ratio;
    final water = coffee * ratio;

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
                  child: Text(_isEdit ? 'Reçeteyi Düzenle' : 'Yeni Reçete',
                      style: const TextStyle(
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
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reçete adı', hintText: 'Örn. Sabah V60’ı'),
            ),
            const SizedBox(height: 12),
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
                    decoration: const InputDecoration(labelText: 'Sıcaklık (°C)'),
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
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
                  hintText: 'Öğütüm incelik, tat notları…'),
            ),
            const SizedBox(height: 16),
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
                  Text('Tahmini su: ',
                      style: TextStyle(color: AppColors.coffee)),
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
                child: Text(_isEdit ? 'Kaydet' : 'Reçeteyi Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reçete düzenlemeyi köprüden çağırmak için küçük yardımcı.
class RecetasScreenBridge {
  static void openForm(BuildContext context, CoffeeRecipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecipeFormSheet(existing: recipe),
    );
  }
}
