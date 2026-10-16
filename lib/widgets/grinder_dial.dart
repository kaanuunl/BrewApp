import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GrinderDial extends StatefulWidget {
  const GrinderDial({
    super.key,
    required this.value,
    required this.unit,
    required this.step,
    required this.onChanged,
    this.enabled = true,
  });

  final double value;
  final String unit;
  final double step;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  State<GrinderDial> createState() => _GrinderDialState();
}

class _GrinderDialState extends State<GrinderDial> {
  double _turns = 0;
  double? _lastPointerAngle;
  double _dragRemainder = 0;
  double _swipeRemainder = 0;

  void _change(int direction) {
    if (!widget.enabled) return;
    setState(() => _turns += direction / 24);
    widget.onChanged(widget.value + direction * widget.step);
  }

  double _angleAt(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return math.atan2(position.dy - center.dy, position.dx - center.dx);
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    if (!widget.enabled) return;
    _lastPointerAngle = _angleAt(details.localPosition, size);
    _dragRemainder = 0;
    _swipeRemainder = 0;
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (!widget.enabled || _lastPointerAngle == null) return;
    final angle = _angleAt(details.localPosition, size);
    var delta = angle - _lastPointerAngle!;
    if (delta > math.pi) delta -= math.pi * 2;
    if (delta < -math.pi) delta += math.pi * 2;
    _lastPointerAngle = angle;
    _dragRemainder += delta;

    const radiansPerStep = math.pi / 8;
    final angularSteps = (_dragRemainder / radiansPerStep).truncate();
    var steps = angularSteps;
    if (steps == 0) {
      _swipeRemainder += details.delta.dx;
      steps = (_swipeRemainder / 14).truncate();
      if (steps != 0) _swipeRemainder -= steps * 14;
    }
    if (steps == 0) return;
    _dragRemainder -= angularSteps * radiansPerStep;
    setState(() => _turns += steps / 24);
    widget.onChanged(widget.value + steps * widget.step);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accentCaramel;
    final surface = context.containerMilk;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final dial = SizedBox(
      width: 152,
      height: 152,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) => _handlePanStart(details, const Size(152, 152)),
        onPanUpdate: (details) =>
            _handlePanUpdate(details, const Size(152, 152)),
        onPanEnd: (_) => _lastPointerAngle = null,
        child: AnimatedRotation(
          turns: _turns,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: CustomPaint(
            painter: _DialPainter(
              accent: accent,
              track: context.borderLatte,
              enabled: widget.enabled,
            ),
            child: Center(
              child: Transform.rotate(
                angle: -_turns * math.pi * 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grain_rounded,
                      size: 21,
                      color: widget.enabled
                          ? context.accentCoffee
                          : context.textSecondary,
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        _displayValue(widget.value),
                        key: ValueKey(widget.value),
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Text(
                      widget.unit,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _DialButton(
          tooltip: 'Decrease setting',
          icon: Icons.remove,
          onPressed: widget.enabled ? () => _change(-1) : null,
          background: surface,
        ),
        const SizedBox(width: 14),
        dial,
        const SizedBox(width: 14),
        _DialButton(
          tooltip: 'Increase setting',
          icon: Icons.add,
          onPressed: widget.enabled ? () => _change(1) : null,
          background: surface,
        ),
      ],
    );
  }

  String _displayValue(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

class _DialButton extends StatelessWidget {
  const _DialButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.background,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: context.accentCoffee,
        fixedSize: const Size(44, 44),
      ),
      icon: Icon(icon),
    );
  }
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.accent,
    required this.track,
    required this.enabled,
  });

  final Color accent;
  final Color track;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 68.0;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final tickPaint = Paint()
      ..color = enabled ? accent.withValues(alpha: 0.65) : track
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var tick = 0; tick < 36; tick++) {
      final angle = tick * math.pi * 2 / 36 - math.pi / 2;
      final major = tick % 3 == 0;
      final inner = radius - (major ? 11 : 7);
      final outer = radius - 1;
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        tickPaint..strokeWidth = major ? 2.5 : 1.5,
      );
    }

    final indicatorPaint = Paint()
      ..color = enabled ? accent : track
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, center + Offset(0, -radius + 8), indicatorPaint);
    canvas.drawCircle(
      center,
      48,
      Paint()..color = accent.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      accent != oldDelegate.accent ||
      track != oldDelegate.track ||
      enabled != oldDelegate.enabled;
}
