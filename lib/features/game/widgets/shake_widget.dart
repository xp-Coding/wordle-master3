import 'dart:math';
import 'package:flutter/material.dart';

class ShakeController extends ChangeNotifier {
  void shake() {
    notifyListeners();
  }
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final ShakeController controller;
  final Duration duration;
  final double shakeOffset;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.controller,
    this.duration = const Duration(milliseconds: 350),
    this.shakeOffset = 8.0,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    widget.controller.addListener(_triggerShake);
  }

  void _triggerShake() {
    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_triggerShake);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Damped sinusoidal oscillation: sin(4 * pi * t) * (1 - t)
        final t = _animationController.value;
        final offset = sin(4 * 2 * pi * t) * (1 - t) * widget.shakeOffset;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: widget.child,
        );
      },
    );
  }
}
