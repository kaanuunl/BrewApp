import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animated_entry.dart';
import '../widgets/app_header.dart';
import 'method_detail_screen.dart';

class MethodsScreen extends StatefulWidget {
  const MethodsScreen({super.key});

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final active =     context.select<AppState, int>((state) => state.activeTabIndex) ==
    AppState.methodsTabIndex;
    final methods = BrewMethodsData.all.where((m) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
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
                    title: 'Brewing Methods',
                    subtitle:
                        '${methods.length} methods • ratio, grind, and temperature',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search methods or styles…',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.accentCoffee,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.containerMilk,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderLatte),
                  ),
                  child: Text(
                    'Use recipes as starting points. Weigh the coffee, measure the water and time, then adjust one variable at a time in small steps to suit your taste.',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: methods.length,
                itemBuilder: (context, i) => AnimatedEntry(
                  key: ValueKey(methods[i].id),
                  index: i,
                  active: active,
                  child: _MethodCard(method: methods[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.method});
  final BrewMethod method;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MethodDetailScreen(method: method)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.containerMilk,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(method.icon, color: context.accentCoffee, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        _Badge(label: method.difficulty.label),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      method.subtitle,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _Meta(
                          icon: Icons.scale_outlined,
                          text: fmtRatio(method.ratio),
                        ),
                        _Meta(
                          icon: Icons.thermostat_outlined,
                          text: '${method.waterTempC}°C',
                        ),
                        _Meta(
                          icon: Icons.timer_outlined,
                          text: fmtLongDuration(method.totalTimeSeconds),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: context.accentCoffee),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.accentCaramel.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.accentCaramel,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.accentCoffee),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: context.textPrimary)),
      ],
    );
  }
}
