import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({
    super.key,
    required this.child,
    this.index = 0,
    this.active = true,
  });

  final Widget child;
  final int index;
  final bool active;

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  Timer? _staggerTimer;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = curve;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(begin: 0.96, end: 1).animate(curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationStarted) return;
    _animationStarted = true;

    if (!widget.active || MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }

    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller
          ..stop()
          ..value = 0;
        _startAnimation();
      }
    }
  }

  void _startAnimation() {
    _staggerTimer = Timer(
      Duration(milliseconds: widget.index.clamp(0, 6) * 45),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
