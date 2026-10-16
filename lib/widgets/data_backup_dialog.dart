import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Veri yedekleme, geri yükleme ve tema ayarları modal penceresi.
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
          '${state.recipes.length} reçete ve ${state.logs.length} günlük kaydı panoya kopyalandı! 📋',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Panoda metin bulunamadı.')),
      );
    }
  }

  void _importBackup(AppState state) {
    final text = _jsonCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yedek JSON verisini yapıştırın.')),
      );
      return;
    }

    final success = state.importBackupJson(text);
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yedek başarıyla içe aktarıldı! 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hata: Geçersiz yedek JSON biçimi.'),
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
                  child: Icon(Icons.tune, color: context.accentCoffee, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayarlar & Veri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Tema ve veri yedekleme',
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
              'Görünüm Teması',
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
                  label: Text('Sistem'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Krem'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Espresso'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (s) => state.setThemeMode(s.first),
            ),
            const SizedBox(height: 24),
            Text(
              'Veri Yönetimi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kayıtlı reçeteler ve günlük kayıtları cihazında saklanır.',
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
                        '${state.recipes.length} reçete  •  ${state.logs.length} demleme kaydı',
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
                          label: const Text('Yedek Al'),
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
                          label: Text(_importMode ? 'Kapat' : 'Geri Yükle'),
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
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'Yedek JSON verisini buraya yapıştırın...',
                        suffixIcon: IconButton(
                          tooltip: 'Panodan Yapıştır',
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
                        label: const Text('Yedekten Yükle'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
