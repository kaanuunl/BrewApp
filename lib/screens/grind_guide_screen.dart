import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/brew_methods_data.dart';
import '../models/brew_method.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animated_entry.dart';
import 'method_detail_screen.dart';

class GrindGuideScreen extends StatefulWidget {
  const GrindGuideScreen({super.key});

  @override
  State<GrindGuideScreen> createState() => _GrindGuideScreenState();
}

class _GrindGuideScreenState extends State<GrindGuideScreen> {
  String _methodId = 'v60';

  @override
  Widget build(BuildContext context) {
    final method = BrewMethodsData.byId(_methodId);
    final guide = _grindGuideFor(method);

    return Scaffold(
      appBar: AppBar(title: const Text('Grind guide')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isDark
                    ? [const Color(0xFF503626), const Color(0xFF2C211B)]
                    : [AppColors.espresso, AppColors.coffee],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tune, color: Colors.white, size: 34),
                SizedBox(height: 14),
                Text(
                  'Grind controls the flow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'There is no single “best” setting. Start with a setting suited to your equipment and coffee, then make small adjustments by tasting.',
                  style: TextStyle(color: Colors.white, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Choose a brewing method',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _methodId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.coffee_outlined),
            ),
            items: [
              for (final item in BrewMethodsData.all)
                DropdownMenuItem(value: item.id, child: Text(item.name)),
            ],
            onChanged: (id) {
              if (id != null) setState(() => _methodId = id);
            },
          ),
          const SizedBox(height: 16),
          _GrindParticleAnimation(
            key: ValueKey('grind-visual-${method.id}'),
            method: method,
            particleScale: _particleScaleFor(method),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
            child: _SelectedMethodCard(
              key: ValueKey(method.id),
              method: method,
              guide: guide,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntry(
            index: 1,
            child: _GuideCard(
              icon: Icons.grain_outlined,
              title: 'How does grind size affect brewing?',
              body: 'A finer grind generally slows flow and increases extraction; a coarser grind speeds flow and reduces extraction. Brew method, filter, dose, and pouring also affect the result, so grind alone does not determine it.',
            ),
          ),
          AnimatedEntry(
            index: 2,
            child: _GuideCard(
              icon: Icons.coffee_outlined,
              title: 'Adjust to taste',
              rows: const [
                (
                  'Sour, thin, or weak',
                  'Grind a little finer or extend the contact time.',
                ),
                (
                  'Bitter, dry, or too intense',
                  'Grind a little coarser or shorten the contact time.',
                ),
                (
                  'Flow stalls or is very slow',
                  'Grind coarser and check the filter and coffee bed.',
                ),
                (
                  'Flow is too fast or watery',
                  'Grind finer and check that the pour and dose are consistent.',
                ),
              ],
            ),
          ),
          AnimatedEntry(
            index: 3,
            child: _GuideCard(
              icon: Icons.precision_manufacturing_outlined,
              title: 'Calibrate your grinder',
              rows: const [
                (
                  'Find the zero point first',
                  'Find your grinder’s safe reference point according to its instructions.',
                ),
                (
                  'Do not compare numbers',
                  'Click and dial values are not equivalent across brands and models.',
                ),
                (
                  'Change one variable',
                  'Keep the dose and recipe the same, change grind by one small step, and log the result.',
                ),
                (
                  'Espresso',
                  'Track flow time and weighed yield together, and keep the machine and basket settings fixed.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MethodDetailScreen(method: method),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('View the selected method’s brewing steps'),
          ),
        ],
      ),
    );
  }

  _GrindGuide _grindGuideFor(BrewMethod method) {
    if (method.id == 'espresso') {
      return const _GrindGuide(
        title: 'Fine grind',
        texture: 'Starting point: fine table salt',
        explanation: 'Track flow and weigh the beverage yield. If flow is too fast, adjust finer in small steps; if it stalls or is very slow, adjust coarser.',
      );
    }
    if (method.id == 'turkish') {
      return const _GrindGuide(
        title: 'Extra fine / powder',
        texture: 'As fine as flour',
        explanation: 'Turkish coffee requires very fine particles. A home espresso grinder may not reach this setting; use a grinder suitable for Turkish coffee.',
      );
    }
    if (const {'frenchpress', 'coldbrew', 'colddrip'}.contains(method.id)) {
      return _GrindGuide(
        title: method.grindSize.startsWith('Very coarse')
            ? 'Coarse to very coarse'
            : 'Medium-coarse',
        texture: method.grindSize,
        explanation: 'A coarser grind is a useful starting point for longer contact times and the filter or flow design. Make small changes if flow or taste is off.',
      );
    }
    if (const {'moka', 'phin', 'aeropress'}.contains(method.id)) {
      return _GrindGuide(
        title: method.grindSize,
        texture: 'Starting point: medium-fine to fine',
        explanation: 'Pressure and filter design affect flow. Follow the brewer’s instructions; grind coarser if flow stalls or is too slow.',
      );
    }
    return _GrindGuide(
      title: method.grindSize,
      texture: 'Starting point: medium to medium-fine',
      explanation: 'Fine-tune according to filter flow. Grind coarser if drawdown is very slow and the cup tastes dry; finer if flow is fast and taste is weak.',
    );
  }

  double _particleScaleFor(BrewMethod method) {
    if (method.id == 'turkish') return 0.45;
    if (method.id == 'espresso') return 0.75;
    if (const {'frenchpress', 'coldbrew', 'colddrip'}.contains(method.id)) {
      return 1.7;
    }
    return 1.0;
  }
}

class _GrindParticleAnimation extends StatefulWidget {
  const _GrindParticleAnimation({
    super.key,
    required this.method,
    required this.particleScale,
  });

  final BrewMethod method;
  final double particleScale;

  @override
  State<_GrindParticleAnimation> createState() =>
      _GrindParticleAnimationState();
}

class _GrindParticleAnimationState extends State<_GrindParticleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.cardFoam,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.rotate(
                angle: math.sin(_controller.value * math.pi * 2) * 0.045,
                child: child,
              ),
              child: Icon(
                Icons.settings_rounded,
                color: context.accentCaramel,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grind particle visualization',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.method.grindSize,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 94,
              height: 54,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ParticlePainter(
                    progress: _controller.value,
                    particleScale: widget.particleScale,
                    color: context.accentCoffee,
                    background: context.containerMilk,
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

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.progress,
    required this.particleScale,
    required this.color,
    required this.background,
  });

  final double progress;
  final double particleScale;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()..color = background;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      paint,
    );

    for (var index = 0; index < 24; index++) {
      final lane = index % 4;
      final startX = (index * 37 % 100) / 100 * size.width;
      final x =
          (startX + progress * size.width * (0.7 + lane * 0.12)) % size.width;
      final y = centerY + (lane - 1.5) * 9 + math.sin(index * 1.7) * 4;
      final radius = (1.1 + (index % 3) * 0.45) * particleScale;
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      particleScale != oldDelegate.particleScale ||
      color != oldDelegate.color ||
      background != oldDelegate.background;
}

class _SelectedMethodCard extends StatelessWidget {
  const _SelectedMethodCard({
    super.key,
    required this.method,
    required this.guide,
  });

  final BrewMethod method;
  final _GrindGuide guide;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.cardFoam,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(method.icon, color: context.accentCoffee, size: 25),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    method.name,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  fmtRatio(method.ratio),
                  style: TextStyle(
                    color: context.accentCoffee,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              guide.title,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              guide.texture,
              style: TextStyle(
                color: context.accentCoffee,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              guide.explanation,
              style: TextStyle(
                color: context.textSecondary,
                height: 1.45,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ParameterPill(
                  icon: Icons.thermostat_outlined,
                  text: '${method.waterTempC}°C',
                ),
                _ParameterPill(
                  icon: Icons.timer_outlined,
                  text: fmtLongDuration(method.totalTimeSeconds),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    this.body,
    this.rows = const [],
  });

  final IconData icon;
  final String title;
  final String? body;
  final List<(String, String)> rows;

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
                Icon(icon, color: context.accentCoffee),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (body != null) ...[
              const SizedBox(height: 10),
              Text(
                body!,
                style: TextStyle(
                  color: context.textSecondary,
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
            ],
            for (final row in rows) ...[
              const SizedBox(height: 12),
              Text(
                row.$1,
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                row.$2,
                style: TextStyle(
                  color: context.textSecondary,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ParameterPill extends StatelessWidget {
  const _ParameterPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.containerMilk,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: context.accentCoffee),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrindGuide {
  const _GrindGuide({
    required this.title,
    required this.texture,
    required this.explanation,
  });

  final String title;
  final String texture;
  final String explanation;
}
