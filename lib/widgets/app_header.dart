import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'data_backup_dialog.dart';

/// Tüm ana sekmelerde tutarlı başlık, tema değiştirici ve ayarlar butonları sunan bileşen.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.actions,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    IconData themeIcon;
    switch (state.themeMode) {
      case ThemeMode.system:
        themeIcon = Icons.brightness_auto_outlined;
        break;
      case ThemeMode.light:
        themeIcon = Icons.light_mode_outlined;
        break;
      case ThemeMode.dark:
        themeIcon = Icons.dark_mode_outlined;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.containerMilk,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: context.accentCoffee, size: 24),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...?actions,
        IconButton(
          tooltip: 'Tema Değiştir (Açık/Koyu/Sistem)',
          icon: Icon(themeIcon, color: context.accentCoffee, size: 22),
          onPressed: () => state.cycleThemeMode(),
        ),
        IconButton(
          tooltip: 'Ayarlar ve Yedekleme',
          icon: Icon(Icons.tune_outlined, color: context.accentCoffee, size: 22),
          onPressed: () => DataManagementSheet.show(context),
        ),
      ],
    );
  }
}
