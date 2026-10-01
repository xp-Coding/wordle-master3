enum LetterState {
  empty,
  filled,
  correct,   // Exact match (Green)
  misplaced, // Wrong spot (Yellow)
  absent,    // Not in word (Gray)
}

class LetterEvaluation {
  final String char;
  final LetterState state;

  const LetterEvaluation({
    required this.char,
    required this.state,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LetterEvaluation &&
          runtimeType == other.runtimeType &&
          char == other.char &&
          state == other.state;

  @override
  int get hashCode => char.hashCode ^ state.hashCode;

  @override
  String toString() => 'LetterEvaluation(char: $char, state: $state)';
}

/// Production Two-Pass Wordle Validation Engine
/// Accurately evaluates guess words against target solutions handling duplicate letters.
class WordleEvaluator {
  /// Evaluates a [guess] against a [target] word.
  ///
  /// Pass 1: Identify all exact index matches and mark as `Correct`.
  /// Target counts for matched letters are decremented.
  ///
  /// Pass 2: Iterate over remaining unmatched positions. If the guessed
  /// character exists in the remaining available target character pool,
  /// mark as `Misplaced` and decrement pool count. Otherwise mark as `Absent`.
  static List<LetterEvaluation> evaluate({
    required String guess,
    required String target,
  }) {
    final cleanGuess = guess.toUpperCase().trim();
    final cleanTarget = target.toUpperCase().trim();
    final length = cleanGuess.length;

    assert(
      length == cleanTarget.length,
      'Guess ($cleanGuess) and Target ($cleanTarget) lengths must match.',
    );

    final result = List<LetterState>.filled(length, LetterState.absent);
    final targetLetterCounts = <String, int>{};

    // Build frequency map of target letters
    for (int i = 0; i < length; i++) {
      final char = cleanTarget[i];
      targetLetterCounts[char] = (targetLetterCounts[char] ?? 0) + 1;
    }

    // PASS 1: Identify exact index matches (Green)
    for (int i = 0; i < length; i++) {
      final guessChar = cleanGuess[i];
      final targetChar = cleanTarget[i];

      if (guessChar == targetChar) {
        result[i] = LetterState.correct;
        targetLetterCounts[guessChar] = targetLetterCounts[guessChar]! - 1;
      }
    }

    // PASS 2: Match remaining letters against available pool (Yellow / Gray)
    for (int i = 0; i < length; i++) {
      if (result[i] == LetterState.correct) {
        continue; // Already evaluated
      }

      final guessChar = cleanGuess[i];
      final remainingCount = targetLetterCounts[guessChar] ?? 0;

      if (remainingCount > 0) {
        result[i] = LetterState.misplaced;
        targetLetterCounts[guessChar] = remainingCount - 1;
      } else {
        result[i] = LetterState.absent;
      }
    }

    return List.generate(
      length,
      (i) => LetterEvaluation(
        char: cleanGuess[i],
        state: result[i],
      ),
    );
  }

  /// Helper to check if a guess is a complete win
  static bool isWin(List<LetterEvaluation> evaluations) {
    if (evaluations.isEmpty) return false;
    return evaluations.every((e) => e.state == LetterState.correct);
  }
}
