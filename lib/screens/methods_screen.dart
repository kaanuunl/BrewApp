import 'package:flutter/material.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'method_detail_screen.dart';

/// Demleme yöntemleri kütüphanesi.
class MethodsScreen extends StatefulWidget {
  const MethodsScreen({super.key});

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
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
                  Text('Demleme Yöntemleri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.espresso)),
                  const SizedBox(height: 4),
                  Text('${methods.length} yöntem • oran, öğütüm ve sıcaklık',
                      style: TextStyle(color: AppColors.coffee)),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Yöntem ara…',
                      prefixIcon: Icon(Icons.search, color: AppColors.coffee),
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
                itemBuilder: (context, i) =>
                    _MethodCard(method: methods[i]),
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
          MaterialPageRoute(
            builder: (_) => MethodDetailScreen(method: method),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.milk,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(method.icon, color: AppColors.coffee, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(method.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        _Badge(label: method.difficulty.label),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(method.subtitle,
                        style: TextStyle(
                            color: AppColors.coffee.withValues(alpha: 0.8),
                            fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Meta(icon: Icons.scale_outlined, text: fmtRatio(method.ratio)),
                        const SizedBox(width: 14),
                        _Meta(icon: Icons.thermostat_outlined, text: '${method.waterTempC}°C'),
                        const SizedBox(width: 14),
                        _Meta(icon: Icons.timer_outlined, text: fmtLongDuration(method.totalTimeSeconds)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.coffee),
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
        color: AppColors.caramel.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              color: AppColors.caramel,
              fontSize: 11,
              fontWeight: FontWeight.w700)),
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
        Icon(icon, size: 14, color: AppColors.coffee),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 12, color: AppColors.espresso)),
      ],
    );
  }
}
