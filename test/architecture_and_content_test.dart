import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle_master/core/data/classic_levels.dart';
import 'package:wordle_master/core/data/three_clues_levels.dart';
import 'package:wordle_master/core/data/word_connect_levels.dart';
import 'package:wordle_master/core/data/word_dictionary.dart';
import 'package:wordle_master/core/services/game_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordDictionary Tests', () {
    final dict = WordDictionary();

    test('Contains minimum 2,500+ accepted words (actually 6,400+)', () {
      expect(dict.wordCount, greaterThanOrEqualTo(2500));
    });

    test('Validates common 4, 5, and 6 letter words', () {
      expect(dict.isValidWord('BIRD'), isTrue);
      expect(dict.isValidWord('CRANE'), isTrue);
      expect(dict.isValidWord('PLANET'), isTrue);
      expect(dict.isValidWord('XZQQW'), isFalse);
    });

    test('Produces random and daily deterministic words correctly', () {
      final w4 = dict.getRandomWord(4);
      final w5 = dict.getRandomWord(5);
      final w6 = dict.getRandomWord(6);
      expect(w4.length, equals(4));
      expect(w5.length, equals(5));
      expect(w6.length, equals(6));

      final today = DateTime.utc(2026, 10, 8);
      final daily1 = dict.getDailyWord(today);
      final daily2 = dict.getDailyWord(today);
      expect(daily1, equals(daily2));
    });
  });

  group('ClassicLevels Tests', () {
    test('Contains exactly 50 progressive levels', () {
      expect(ClassicLevels.levels.length, equals(50));
    });

    test('Scales from 4-letter (1-15) to 5-letter (16-40) to 6-letter (41-50)', () {
      for (int i = 1; i <= 15; i++) {
        final lvl = ClassicLevels.getLevel(i);
        expect(lvl.wordLength, equals(4), reason: 'Level $i should be 4 letters');
        expect(lvl.emojiClues.length, greaterThanOrEqualTo(3));
      }

      for (int i = 16; i <= 40; i++) {
        final lvl = ClassicLevels.getLevel(i);
        expect(lvl.wordLength, equals(5), reason: 'Level $i should be 5 letters');
        expect(lvl.emojiClues.length, greaterThanOrEqualTo(3));
      }

      for (int i = 41; i <= 50; i++) {
        final lvl = ClassicLevels.getLevel(i);
        expect(lvl.wordLength, equals(6), reason: 'Level $i should be 6 letters');
        expect(lvl.emojiClues.length, greaterThanOrEqualTo(3));
      }
    });

    test('Specific target words and contextual emoji clues', () {
      final lvl29 = ClassicLevels.getLevel(29);
      expect(lvl29.targetWord, equals('MAGIC'));
      expect(lvl29.emojiClues, contains('✨'));

      final lvl48 = ClassicLevels.getLevel(48);
      expect(lvl48.targetWord, equals('ORANGE'));
      expect(lvl48.emojiClues, contains('🍊'));
    });
  });

  group('ThreeCluesLevels Tests', () {
    test('Contains exactly 50 progressive deduction levels', () {
      expect(ThreeCluesLevels.levels.length, equals(50));
    });

    test('Each level contains 3 clue strings and non-empty solution', () {
      for (final puzzle in ThreeCluesLevels.levels) {
        expect(puzzle.clues.length, equals(3));
        expect(puzzle.solution.isNotEmpty, isTrue);
      }
    });

    test('Bank letters are randomized and do not place solution at start', () {
      final puzzle1 = ThreeCluesLevels.getPuzzle(1);
      final bank = puzzle1.generateBankLetters(totalBankSize: 12);
      expect(bank.length, equals(12));
      // Verify all characters of DOG are present in the bank
      for (final char in puzzle1.solution.split('')) {
        expect(bank, contains(char));
      }
      // Bank does not start with DOG
      expect(bank.take(3).join(), isNot(equals('DOG')));
    });
  });

  group('WordConnectLevels Tests', () {
    test('Contains exactly 50 progressive levels', () {
      expect(WordConnectLevels.levels.length, equals(50));
    });

    test('Each level defines wheel letters and target words', () {
      for (final level in WordConnectLevels.levels) {
        expect(level.letters.length, greaterThanOrEqualTo(4));
        expect(level.targetWords.length, greaterThanOrEqualTo(3));
        expect(level.targetWords, contains(level.primaryWord));
      }
    });
  });

  group('GameStorage Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await GameStorage().init();
    });

    test('Default values: coins=200, levels=1', () {
      final storage = GameStorage();
      expect(storage.coins, equals(200));
      expect(storage.classicLevel, equals(1));
      expect(storage.wordConnectLevel, equals(1));
      expect(storage.threeCluesLevel, equals(1));
      expect(storage.canFreeSpin, isTrue);
    });

    test('Advancing levels clamps at 50', () async {
      final storage = GameStorage();
      await storage.setClassicLevel(49);
      expect(storage.classicLevel, equals(49));
      await storage.advanceClassicLevel();
      expect(storage.classicLevel, equals(50));
      await storage.advanceClassicLevel();
      expect(storage.classicLevel, equals(50));
    });

    test('Spin cooldown logic enforces 24 hours', () async {
      final storage = GameStorage();
      expect(storage.canFreeSpin, isTrue);
      await storage.recordFreeSpinUsed();
      expect(storage.canFreeSpin, isFalse);
      expect(storage.timeUntilNextFreeSpin.inHours, greaterThanOrEqualTo(23));
    });

    test('Milestone chests claim correctly', () async {
      final storage = GameStorage();
      expect(storage.isMilestoneClaimed(3), isFalse);

      // Not enough wins yet
      final canClaimBefore = await storage.claimMilestoneChest(3, 150);
      expect(canClaimBefore, isFalse);

      // Record 3 wins
      await storage.recordDailyWin('2026-10-01');
      await storage.recordDailyWin('2026-10-02');
      await storage.recordDailyWin('2026-10-03');
      expect(storage.monthlyDailyWins, equals(3));

      // Now claim bronze chest
      final canClaimAfter = await storage.claimMilestoneChest(3, 150);
      expect(canClaimAfter, isTrue);
      expect(storage.isMilestoneClaimed(3), isTrue);
      expect(storage.coins, equals(350)); // 200 initial + 150 bonus

      // Cannot double claim
      final doubleClaim = await storage.claimMilestoneChest(3, 150);
      expect(doubleClaim, isFalse);
    });
  });
}
