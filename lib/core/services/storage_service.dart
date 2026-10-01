import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Coins & Economy
  int get coins => _prefs.getInt('user_coins') ?? 200;
  Future<bool> setCoins(int amount) async {
    return await _prefs.setInt('user_coins', amount.clamp(0, 999999));
  }

  Future<bool> addCoins(int amount) async {
    return await setCoins(coins + amount);
  }

  Future<bool> deductCoins(int amount) async {
    if (coins < amount) return false;
    return await setCoins(coins - amount);
  }

  // Level & XP
  int get xp => _prefs.getInt('player_xp') ?? 0;
  int get level => (xp ~/ 100) + 1;

  Future<void> addXp(int amount) async {
    await _prefs.setInt('player_xp', xp + amount);
  }

  // Piggy Bank
  int get piggyBankCoins => _prefs.getInt('piggy_bank_coins') ?? 50;
  static const int piggyBankCapacity = 300;

  Future<void> addPiggyCoins(int amount) async {
    final current = piggyBankCoins;
    final updated = (current + amount).clamp(0, piggyBankCapacity);
    await _prefs.setInt('piggy_bank_coins', updated);
  }

  Future<int> claimPiggyBank() async {
    final collected = piggyBankCoins;
    if (collected > 0) {
      await addCoins(collected);
      await _prefs.setInt('piggy_bank_coins', 0);
    }
    return collected;
  }

  // Sound Settings
  bool get isSoundEnabled => _prefs.getBool('sound_enabled') ?? true;
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }

  // Board Word Length Preference (4, 5, 6)
  int get wordLength => _prefs.getInt('word_length_preference') ?? 5;
  Future<void> setWordLength(int length) async {
    await _prefs.setInt('word_length_preference', length);
  }

  // Daily Puzzle & Streak
  int get dailyStreak => _prefs.getInt('daily_streak') ?? 0;
  String? get lastDailyDate => _prefs.getString('last_daily_date');

  bool get isDailyCompletedToday {
    final today = _getTodayUtcString();
    return lastDailyDate == today;
  }

  Future<void> recordDailyCompletion() async {
    final today = _getTodayUtcString();
    final yesterday = _getYesterdayUtcString();

    if (lastDailyDate == yesterday) {
      await _prefs.setInt('daily_streak', dailyStreak + 1);
    } else if (lastDailyDate != today) {
      await _prefs.setInt('daily_streak', 1);
    }
    await _prefs.setString('last_daily_date', today);
  }

  // Daily Lucky Spin
  String? get lastDailySpinDate => _prefs.getString('last_daily_spin_date');
  bool get canSpinToday {
    final today = _getTodayUtcString();
    return lastDailySpinDate != today;
  }

  Future<void> recordDailySpinClaimed() async {
    final today = _getTodayUtcString();
    await _prefs.setString('last_daily_spin_date', today);
  }

  // Overall Statistics
  int get gamesPlayed => _prefs.getInt('stat_games_played') ?? 0;
  int get gamesWon => _prefs.getInt('stat_games_won') ?? 0;
  int get currentStreak => _prefs.getInt('stat_current_streak') ?? 0;
  int get maxStreak => _prefs.getInt('stat_max_streak') ?? 0;

  Future<void> recordGameResult({required bool won}) async {
    final played = gamesPlayed + 1;
    await _prefs.setInt('stat_games_played', played);

    if (won) {
      final wonCount = gamesWon + 1;
      final newStreak = currentStreak + 1;
      final bestStreak = newStreak > maxStreak ? newStreak : maxStreak;
      await _prefs.setInt('stat_games_won', wonCount);
      await _prefs.setInt('stat_current_streak', newStreak);
      await _prefs.setInt('stat_max_streak', bestStreak);
      await addXp(25);
      await addPiggyCoins(15);
    } else {
      await _prefs.setInt('stat_current_streak', 0);
    }
  }

  String _getTodayUtcString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getYesterdayUtcString() {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}
