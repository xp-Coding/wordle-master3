import '../data/word_dictionary.dart';

export '../data/word_dictionary.dart';

/// Legacy DictionaryService Adapter that wraps the massive WordDictionary
class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal();

  final WordDictionary _dict = WordDictionary();

  /// Checks whether [word] exists in the 6,400+ canonical dictionary
  bool isValidWord(String word) {
    return _dict.isValidWord(word);
  }

  /// Returns a random solution for the given [length] (4, 5, or 6)
  String getRandomSolution(int length) {
    return _dict.getRandomWord(length);
  }

  /// Daily Seeded Solution: Deterministic word for the given UTC date
  String getDailySolution(DateTime dateUtc) {
    return _dict.getDailyWord(dateUtc);
  }
}
