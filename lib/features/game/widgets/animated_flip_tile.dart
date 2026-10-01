import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/logic/wordle_evaluator.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedFlipTile extends StatefulWidget {
  final String letter;
  final LetterState state;
  final int columnIndex;
  final bool isRevealed;
  final bool isWinningBounce;

  const AnimatedFlipTile({
    super.key,
    required this.letter,
    required this.state,
    required this.columnIndex,
    required this.isRevealed,
    this.isWinningBounce = false,
  });

  @override
  State<AnimatedFlipTile> createState() => _AnimatedFlipTileState();
}

class _AnimatedFlipTileState extends State<AnimatedFlipTile>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _popController;
  late Animation<double> _popAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  bool _showBackFace = false;

  @override
  void initState() {
    super.initState();

    // 1. 3D Perspective Flip Controller (180 deg on X-axis)
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutBack,
      ),
    )..addListener(() {
        if (_flipAnimation.value >= pi / 2 && !_showBackFace) {
          setState(() {
            _showBackFace = true;
          });
        }
      });

    // 2. Typing 1.15x Pop Controller
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _popAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
    ]).animate(_popController);

    // 3. Victory Harmonic Bounce Controller
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -14.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -14.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    if (widget.isRevealed) {
      _showBackFace = true;
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFlipTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger typing pop when letter is added
    if (widget.letter.isNotEmpty && oldWidget.letter.isEmpty) {
      _popController.forward(from: 0.0);
    }

    // Trigger staggered 3D flip when row is revealed
    if (widget.isRevealed && !oldWidget.isRevealed) {
      final staggerDelay = Duration(milliseconds: widget.columnIndex * 80);
      Future.delayed(staggerDelay, () {
        if (mounted) {
          _flipController.forward(from: 0.0);
        }
      });
    }

    // Trigger victory bounce wave
    if (widget.isWinningBounce && !oldWidget.isWinningBounce) {
      final staggerDelay = Duration(milliseconds: widget.columnIndex * 100);
      Future.delayed(staggerDelay, () {
        if (mounted) {
          _bounceController.forward(from: 0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _popController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _getTileColor(LetterState state) {
    if (!_showBackFace) {
      return widget.letter.isNotEmpty ? AppColors.tileFilled : AppColors.tileEmpty;
    }
    switch (state) {
      case LetterState.correct:
        return AppColors.tileCorrect;
      case LetterState.misplaced:
        return AppColors.tileMisplaced;
      case LetterState.absent:
        return AppColors.tileAbsent;
      case LetterState.filled:
        return AppColors.tileFilled;
      case LetterState.empty:
        return AppColors.tileEmpty;
    }
  }

  Color _getTileBorderColor(LetterState state) {
    if (!_showBackFace) {
      return widget.letter.isNotEmpty
          ? AppColors.tileFilledBorder
          : AppColors.tileEmptyBorder;
    }
    switch (state) {
      case LetterState.correct:
        return AppColors.tileCorrectBevel;
      case LetterState.misplaced:
        return AppColors.tileMisplacedBevel;
      case LetterState.absent:
        return AppColors.tileAbsentBevel;
      default:
        return AppColors.tileEmptyBorder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnimation, _popAnimation, _bounceAnimation]),
      builder: (context, child) {
        final angle = _flipAnimation.value;
        final isFront = angle < (pi / 2);

        // Perspective transform matrix
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Perspective depth
          ..rotateX(angle);

        // Mirror back face during rotation so text isn't upside-down
        if (!isFront) {
          transform.rotateX(pi);
        }

        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _popAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: transform,
              child: _buildTileBody(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTileBody() {
    final bgColor = _getTileColor(widget.state);
    final borderColor = _getTileBorderColor(widget.state);
    final isCorrect = _showBackFace && widget.state == LetterState.correct;

    return Container(
      margin: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
        boxShadow: [
          // 3D Bevel Shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
          if (isCorrect)
            const BoxShadow(
              color: AppColors.tileCorrectGlow,
              offset: Offset(0, 0),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        widget.letter.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
