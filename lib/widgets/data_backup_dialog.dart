import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../screens/help_legal_screen.dart';
import '../screens/grinder_calibration_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class DataManagementSheet extends StatefulWidget {
  const DataManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const DataManagementSheet(),
    );
  }

  @override
  State<DataManagementSheet> createState() => _DataManagementSheetState();
}

class _DataManagementSheetState extends State<DataManagementSheet> {
  final _jsonCtrl = TextEditingController();
  bool _importMode = false;

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  void _copyBackup(AppState state) {
    final json = state.exportBackupJson();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${state.recipes.length} recipes and ${state.logs.length} journal entries to the clipboard! 📋',
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() => _jsonCtrl.text = data.text!);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No text found on the clipboard.')));
    }
  }

  void _importBackup(AppState state) {
    final text = _jsonCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste backup JSON data first.')),
      );
      return;
    }

    final success = state.importBackupJson(text);
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully! 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid backup JSON format.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmClearLocalData(AppState state) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete data on this device?'),
        content: const Text(
          'Saved recipes, brew journal entries, and theme preference will be permanently deleted. Previously created backups must be deleted separately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete data'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !mounted) return;

    try {
      await state.clearLocalData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App data on this device was deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete data: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.containerMilk,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: context.accentCoffee,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings and Data',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Theme and data backups',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: context.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Appearance theme',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (s) => state.setThemeMode(s.first),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.help_outline, color: context.accentCoffee),
                title: const Text('Help and legal information'),
                subtitle: const Text('FAQ, privacy, and terms of use'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.accentCoffee,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpLegalScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.tune, color: context.accentCoffee),
                title: const Text('Grinder calibration'),
                subtitle: Text(
                  state.grinderCalibration?.grinderName ??
                      'Grinder profile and method settings',
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.accentCoffee,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GrinderCalibrationScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data management',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Saved recipes and journal entries are stored on your device.',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardFoam,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.borderLatte),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.coffee, color: context.accentCoffee, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${state.recipes.length} recipes  •  ${state.logs.length} brew entries',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copyBackup(state),
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Back up'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.accentCoffee,
                            side: BorderSide(color: context.borderLatte),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              setState(() => _importMode = !_importMode),
                          icon: Icon(
                            _importMode ? Icons.close : Icons.download,
                            size: 18,
                          ),
                          label: Text(_importMode ? 'Close' : 'Restore'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.containerMilk,
                            foregroundColor: context.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_importMode) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _jsonCtrl,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste backup JSON data here...',
                        suffixIcon: IconButton(
                          tooltip: 'Paste from clipboard',
                          icon: const Icon(Icons.paste),
                          onPressed: _pasteFromClipboard,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _importBackup(state),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Restore from backup'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmClearLocalData(state),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete data on this device'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
