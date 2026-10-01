import 'package:flutter_test/flutter_test.dart';
import 'package:wordle_master/core/logic/wordle_evaluator.dart';
import 'package:wordle_master/core/services/dictionary_service.dart';

void main() {
  group('WordleEvaluator Tests', () {
    test('Exact match returns all Correct', () {
      final result = WordleEvaluator.evaluate(guess: 'CRANE', target: 'CRANE');
      expect(result.length, 5);
      expect(result.every((e) => e.state == LetterState.correct), isTrue);
      expect(WordleEvaluator.isWin(result), isTrue);
    });

    test('Complete miss returns all Absent', () {
      final result = WordleEvaluator.evaluate(guess: 'PLUMS', target: 'BEACH');
      expect(result.every((e) => e.state == LetterState.absent), isTrue);
      expect(WordleEvaluator.isWin(result), isFalse);
    });

    test('Duplicate letters in guess when target only has one (SPEED vs ERASE)', () {
      // Guess: S P E E D
      // Target: E R A S E
      // 'S': misplaced (exists at idx 3)
      // 'P': absent
      // 'E' (idx 2): misplaced (first E in target)
      // 'E' (idx 3): misplaced / correct if at 4. Target has 2 E's (idx 0 and 4).
      // Guess SPEED:
      // 'S' -> misplaced
      // 'P' -> absent
      // 1st 'E' -> misplaced
      // 2nd 'E' -> misplaced
      // 'D' -> absent
      final result = WordleEvaluator.evaluate(guess: 'SPEED', target: 'ERASE');
      expect(result[0].state, LetterState.misplaced); // S
      expect(result[1].state, LetterState.absent);    // P
      expect(result[2].state, LetterState.misplaced); // 1st E
      expect(result[3].state, LetterState.misplaced); // 2nd E
      expect(result[4].state, LetterState.absent);    // D
    });

    test('Duplicate letters in guess when target has only ONE instance (GEESE vs CRANE)', () {
      // Guess: G E E S E
      // Target: C R A N E
      // Exact match at idx 4 ('E' == 'E') -> correct!
      // Other 'E's at idx 1 and 2 -> must be ABSENT because target only has one 'E' and it's already matched.
      final result = WordleEvaluator.evaluate(guess: 'GEESE', target: 'CRANE');
      expect(result[0].state, LetterState.absent);    // G
      expect(result[1].state, LetterState.absent);    // 1st E (no pool left)
      expect(result[2].state, LetterState.absent);    // 2nd E (no pool left)
      expect(result[3].state, LetterState.absent);    // S
      expect(result[4].state, LetterState.correct);   // 3rd E (exact match)
    });

    test('4-letter and 6-letter words evaluation', () {
      final res4 = WordleEvaluator.evaluate(guess: 'COLD', target: 'GOLD');
      expect(res4[0].state, LetterState.absent);
      expect(res4[1].state, LetterState.correct);
      expect(res4[2].state, LetterState.correct);
      expect(res4[3].state, LetterState.correct);

      final res6 = WordleEvaluator.evaluate(guess: 'SPRING', target: 'STRING');
      expect(res6[0].state, LetterState.correct);
      expect(res6[1].state, LetterState.absent); // P vs T
      expect(res6[2].state, LetterState.correct);
      expect(res6[3].state, LetterState.correct);
      expect(res6[4].state, LetterState.correct);
      expect(res6[5].state, LetterState.correct);
    });
  });

  group('DictionaryService Tests', () {
    final dict = DictionaryService();

    test('Valid words check', () {
      expect(dict.isValidWord('CRANE'), isTrue);
      expect(dict.isValidWord('SLATE'), isTrue);
      expect(dict.isValidWord('XZQQQ'), isFalse);
    });

    test('Daily Seeded Solution is deterministic for same UTC date', () {
      final date1 = DateTime.utc(2026, 10, 1);
      final date2 = DateTime.utc(2026, 10, 1);
      final date3 = DateTime.utc(2026, 10, 2);

      final word1 = dict.getDailySolution(date1);
      final word2 = dict.getDailySolution(date2);
      final word3 = dict.getDailySolution(date3);

      expect(word1, equals(word2));
      expect(word1.length, 5);
      expect(word3.length, 5);
    });
  });
}
