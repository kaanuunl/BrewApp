import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _steam;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _scale = Tween<double>(begin: 0.78, end: 1).animate(curve);
    _steam = Tween<double>(begin: 10, end: 0).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = reduceMotion ? 1.0 : _controller.value;
            return Opacity(
              opacity: progress,
              child: Transform.scale(
                scale: reduceMotion ? 1 : _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 118,
                      height: 118,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.accentCaramel,
                                  context.accentCoffee,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: context.accentCoffee.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.coffee_rounded,
                            size: 52,
                            color: context.isDark
                                ? AppColors.darkCream
                                : Colors.white,
                          ),
                          Positioned(
                            top: reduceMotion ? 7 : 7 + _steam.value,
                            child: Icon(
                              Icons.wb_cloudy_outlined,
                              size: 24,
                              color: context.accentCaramel.withValues(
                                alpha: reduceMotion
                                    ? 0.45
                                    : 0.2 + 0.45 * progress,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Brew App',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Getting your coffee ready',
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 92,
                      child: LinearProgressIndicator(
                        value: progress,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 4,
                        backgroundColor: context.containerMilk,
                        color: context.accentCaramel,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 14),
              Text(
                'Brew App could not start',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An error occurred while reading local settings. Try restarting the app.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
