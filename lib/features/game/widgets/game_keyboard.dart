import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/logic/wordle_evaluator.dart';
import '../../../../core/theme/app_colors.dart';

typedef OnKeyTapped = void Function(String key);

class GameKeyboard extends StatelessWidget {
  final Map<String, LetterState> keyStates;
  final Set<String> eliminatedKeys;
  final OnKeyTapped onKeyTapped;
  final VoidCallback onEnterTapped;
  final VoidCallback onDeleteTapped;

  const GameKeyboard({
    super.key,
    required this.keyStates,
    this.eliminatedKeys = const {},
    required this.onKeyTapped,
    required this.onEnterTapped,
    required this.onDeleteTapped,
  });

  static const List<List<String>> _keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
  ];

  Color _getKeyColor(String key) {
    if (eliminatedKeys.contains(key)) {
      return AppColors.keyEliminated;
    }
    final state = keyStates[key];
    switch (state) {
      case LetterState.correct:
        return AppColors.tileCorrect;
      case LetterState.misplaced:
        return AppColors.tileMisplaced;
      case LetterState.absent:
        return AppColors.tileAbsent;
      default:
        return AppColors.keyDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _keyboardLayout.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isSpecial = key == 'ENTER' || key == 'DEL';
                final isEliminated = eliminatedKeys.contains(key);

                final flex = isSpecial ? 3 : 2;
                final keyColor = _getKeyColor(key);

                return Expanded(
                  flex: flex,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Material(
                      color: keyColor,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                      shadowColor: Colors.black45,
                      child: InkWell(
                        onTap: isEliminated
                            ? null
                            : () {
                                if (key == 'ENTER') {
                                  onEnterTapped();
                                } else if (key == 'DEL') {
                                  onDeleteTapped();
                                } else {
                                  onKeyTapped(key);
                                }
                              },
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.white24,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isEliminated
                                  ? Colors.red.withValues(alpha: 0.3)
                                  : AppColors.keyDefaultBorder.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: _buildKeyContent(key, isEliminated),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyContent(String key, bool isEliminated) {
    if (key == 'DEL') {
      return const Icon(
        Icons.backspace_outlined,
        color: AppColors.textLight,
        size: 20,
      );
    }
    if (key == 'ENTER') {
      return Text(
        'ENTER',
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          key,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isEliminated
                ? AppColors.textMuted.withValues(alpha: 0.3)
                : AppColors.textLight,
          ),
        ),
        if (isEliminated)
          Transform.rotate(
            angle: -0.4,
            child: Container(
              height: 2,
              width: 18,
              color: Colors.redAccent.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }
}
