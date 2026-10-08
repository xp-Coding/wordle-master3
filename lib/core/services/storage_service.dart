import 'game_storage.dart';

/// Legacy StorageService Adapter that delegates to the unified GameStorage architecture.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final GameStorage _storage = GameStorage();

  Future<void> init() async {
    await _storage.init();
  }

  // Coins & Economy
  int get coins => _storage.coins;
  Future<bool> setCoins(int amount) => _storage.setCoins(amount);
  Future<bool> addCoins(int amount) => _storage.addCoins(amount);
  Future<bool> deductCoins(int amount) => _storage.deductCoins(amount);

  // Level & XP
  int get xp => _storage.xp;
  int get level => _storage.playerLevel;
  Future<void> addXp(int amount) => _storage.addXp(amount);

  // Piggy Bank
  int get piggyBankCoins => _storage.piggyBankCoins;
  static const int piggyBankCapacity = GameStorage.piggyBankCapacity;
  Future<void> addPiggyCoins(int amount) => _storage.addPiggyCoins(amount);
  Future<int> claimPiggyBank() => _storage.claimPiggyBank();

  // Sound Settings
  bool get isSoundEnabled => _storage.isSoundEnabled;
  Future<void> setSoundEnabled(bool enabled) => _storage.setSoundEnabled(enabled);

  // Board Word Length Preference
  int get wordLength => _storage.wordLength;
  Future<void> setWordLength(int length) => _storage.setWordLength(length);

  // Daily Puzzle & Streak
  int get dailyStreak => _storage.dailyStreak;
  String? get lastDailyDate => _storage.getTodayUtcDateString();
  bool get isDailyCompletedToday => _storage.isDailyCompletedToday;
  Future<void> recordDailyCompletion() => _storage.recordDailyWin(_storage.getTodayUtcDateString());

  // Daily Lucky Spin
  bool get canSpinToday => _storage.canFreeSpin;
  Future<void> recordDailySpinClaimed() => _storage.recordFreeSpinUsed();

  // Overall Statistics
  int get gamesPlayed => _storage.gamesPlayed;
  int get gamesWon => _storage.gamesWon;
  int get currentStreak => _storage.currentStreak;
  int get maxStreak => _storage.maxStreak;
  Future<void> recordGameResult({required bool won}) => _storage.recordGameResult(won: won);
}
