import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/coffee_recipe.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animated_entry.dart';
import '../widgets/app_header.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recipes = state.recipes;
    final active = state.activeTabIndex == AppState.recipesTabIndex;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'recipe_fab',
        backgroundColor: context.accentCoffee,
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
                  AppHeader(
                    title: 'My recipes',
                    subtitle: recipes.isEmpty
                        ? 'No recipes yet. Tap + to add one.'
                        : '${recipes.length} saved recipes',
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
                      itemBuilder: (context, i) => AnimatedEntry(
                        key: ValueKey(recipes[i].id),
                        index: i,
                        active: active,
                        child: _RecipeCard(recipe: recipes[i]),
                      ),
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
      backgroundColor: context.bgCream,
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
              color: context.containerMilk,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border,
              size: 44,
              color: context.accentCoffee,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save your custom coffee recipes here',
            style: TextStyle(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});
  final CoffeeRecipe recipe;

  void _shareRecipe(BuildContext context) {
    final method = BrewMethodsData.byName(recipe.methodName);
    final text =
        '☕ *${recipe.name}* — ${method.name}\n'
        '⚖️ Coffee: ${fmtNum(recipe.coffeeGrams)} g | ${method.ratioOutputLabel}: ${fmtNum(recipe.waterMl)} ${method.ratioOutputUnit} (${fmtRatio(recipe.ratio)})\n'
        '🌡️ Temperature: ${recipe.waterTempC}°C | ⏱️ Time: ${fmtLongDuration(recipe.totalTimeSeconds)}\n'
        '⚙️ Grind: ${recipe.grindSize}\n'
        '${recipe.notes.isNotEmpty ? "📝 Notes: ${recipe.notes}\n" : ""}'
        '— Made with Brew App ☕';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe copied to clipboard! 📋')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final method = BrewMethodsData.byName(recipe.methodName);

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
                    recipe.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Brew this recipe',
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: context.accentCaramel,
                    size: 28,
                  ),
                  onPressed: () =>
                      context.read<AppState>().startTimerWithRecipe(recipe),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: context.accentCoffee),
                  onSelected: (v) {
                    if (v == 'brew') {
                      context.read<AppState>().startTimerWithRecipe(recipe);
                    } else if (v == 'edit') {
                      RecetasScreenBridge.openForm(context, recipe);
                    } else if (v == 'share') {
                      _shareRecipe(context);
                    } else if (v == 'delete') {
                      context.read<AppState>().deleteRecipe(recipe.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'brew',
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Brew with timer'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share recipe'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
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
            const SizedBox(height: 2),
            Text(
              method.name,
              style: TextStyle(color: context.accentCoffee, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Pill(
                  bg: context.containerMilk,
                  value: '${fmtNum(recipe.coffeeGrams)} g coffee',
                ),
                const SizedBox(width: 8),
                _Pill(
                  bg: context.containerMilk,
                  value:
                      '${fmtNum(recipe.waterMl)} ${method.ratioOutputUnit} ${method.ratioOutputLabel.toLowerCase()}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Pill(
                  bg: context.accentCaramel.withValues(alpha: 0.18),
                  value: fmtRatio(recipe.ratio),
                ),
                const SizedBox(width: 8),
                _Pill(
                  bg: context.accentCaramel.withValues(alpha: 0.18),
                  value: '${recipe.waterTempC}°C',
                ),
                const SizedBox(width: 8),
                _Pill(
                  bg: context.accentCaramel.withValues(alpha: 0.18),
                  value: fmtLongDuration(recipe.totalTimeSeconds),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Grind: ${recipe.grindSize}',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
            if (recipe.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                recipe.notes,
                style: TextStyle(
                  fontSize: 13,
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
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
    );
  }
}

class RecipeFormSheet extends StatefulWidget {
  const RecipeFormSheet({
    super.key,
    this.existing,
    this.initialCoffee,
    this.initialRatio,
  });

  final CoffeeRecipe? existing;
  final double? initialCoffee;
  final double? initialRatio;

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
  String _methodId = 'v60';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final initCoffee = widget.initialCoffee != null
        ? fmtNum(widget.initialCoffee!)
        : (e != null ? fmtNum(e.coffeeGrams) : '18');
    final initRatio = widget.initialRatio != null
        ? fmtNum(widget.initialRatio!)
        : (e != null ? fmtNum(e.ratio) : '16');

    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _coffeeCtrl = TextEditingController(text: initCoffee);
    _ratioCtrl = TextEditingController(text: initRatio);
    _tempCtrl = TextEditingController(
      text: e != null
          ? '${e.waterTempC}'
          : '${BrewMethodsData.byId(_methodId).waterTempC}',
    );
    _timeCtrl = TextEditingController(
      text: e != null ? '${e.totalTimeSeconds}' : '180',
    );
    _notesCtrl = TextEditingController(text: e?.notes ?? '');

    if (e != null) {
      _methodId = BrewMethodsData.byName(e.methodName).id;
    } else if (widget.initialRatio != null) {
      final matching = BrewMethodsData.all
          .where((m) => m.id != 'espresso')
          .firstWhere(
            (m) => (m.ratio - widget.initialRatio!).abs() < 0.5,
            orElse: () => BrewMethodsData.byId('v60'),
          );
      _methodId = matching.id;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a name and a valid coffee amount.'),
        ),
      );
      return;
    }
    final method = BrewMethodsData.byId(_methodId);
    final appState = context.read<AppState>();
    final calibratedGrind = appState.calibratedGrindFor(method.id);
    final recipe = CoffeeRecipe(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      methodName: method.name,
      coffeeGrams: _coffee,
      waterMl: method.outputForCoffee(_coffee),
      ratio: _ratio,
      grindSize: calibratedGrind == null
          ? method.grindSize
          : '$calibratedGrind ${appState.grinderCalibration?.unit ?? 'clicks'}',
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
    final method = BrewMethodsData.byId(_methodId);
    final output = method.outputForCoffee(coffee);

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
                    _isEdit ? 'Edit recipe' : 'New recipe',
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
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Recipe name',
                hintText: 'For example, morning V60',
              ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Grind size, tasting notes…',
              ),
            ),
            const SizedBox(height: 16),
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
                child: Text(_isEdit ? 'Save' : 'Add recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecetasScreenBridge {
  static void openForm(BuildContext context, CoffeeRecipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => RecipeFormSheet(existing: recipe),
    );
  }
}
