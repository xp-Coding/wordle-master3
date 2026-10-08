import 'package:shared_preferences/shared_preferences.dart';

/// Unified Production Game Storage & Persistence Architecture
/// Manages player economy, mode progression (Levels 1–50), streak tracking,
/// calendar wins, and lucky spin cooldowns.
class GameStorage {
  static final GameStorage _instance = GameStorage._internal();
  factory GameStorage() => _instance;
  GameStorage._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ==========================================
  // ECONOMY & COINS
  // ==========================================
  static const int defaultInitialCoins = 200;

  int get coins {
    return _prefs.getInt('user_coins') ?? _prefs.getInt('coins') ?? defaultInitialCoins;
  }

  Future<bool> setCoins(int amount) async {
    final clamped = amount.clamp(0, 9999999);
    await _prefs.setInt('coins', clamped);
    return await _prefs.setInt('user_coins', clamped);
  }

  Future<bool> addCoins(int amount) async {
    return await setCoins(coins + amount);
  }

  Future<bool> deductCoins(int amount) async {
    if (coins < amount) return false;
    return await setCoins(coins - amount);
  }

  // ==========================================
  // PROGRESSIVE LEVEL REPOSITORIES (1–50)
  // ==========================================
  // Classic Wordle (1–50)
  int get classicLevel => _prefs.getInt('classic_level') ?? 1;

  Future<void> setClassicLevel(int level) async {
    await _prefs.setInt('classic_level', level.clamp(1, 50));
  }

  Future<void> advanceClassicLevel() async {
    if (classicLevel < 50) {
      await setClassicLevel(classicLevel + 1);
    }
  }

  // Word Connect / Radial Anagrams (1–50)
  int get wordConnectLevel => _prefs.getInt('word_connect_level') ?? 1;

  Future<void> setWordConnectLevel(int level) async {
    await _prefs.setInt('word_connect_level', level.clamp(1, 50));
  }

  Future<void> advanceWordConnectLevel() async {
    if (wordConnectLevel < 50) {
      await setWordConnectLevel(wordConnectLevel + 1);
    }
  }

  // 3 Clues 1 Word / Association (1–50)
  int get threeCluesLevel => _prefs.getInt('three_clues_level') ?? 1;

  Future<void> setThreeCluesLevel(int level) async {
    await _prefs.setInt('three_clues_level', level.clamp(1, 50));
  }

  Future<void> advanceThreeCluesLevel() async {
    if (threeCluesLevel < 50) {
      await setThreeCluesLevel(threeCluesLevel + 1);
    }
  }

  // ==========================================
  // LUCKY SPIN WHEEL COOLDOWN & PERSISTENCE
  // ==========================================
  static const Duration spinCooldown = Duration(hours: 24);

  int? get lastFreeSpinTimestamp => _prefs.getInt('last_free_spin_timestamp');

  bool get canFreeSpin {
    final timestamp = lastFreeSpinTimestamp;
    if (timestamp == null) return true;
    final lastSpinTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final elapsed = DateTime.now().difference(lastSpinTime);
    return elapsed >= spinCooldown;
  }

  Duration get timeUntilNextFreeSpin {
    final timestamp = lastFreeSpinTimestamp;
    if (timestamp == null) return Duration.zero;
    final lastSpinTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final elapsed = DateTime.now().difference(lastSpinTime);
    final remaining = spinCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> recordFreeSpinUsed() async {
    await _prefs.setInt('last_free_spin_timestamp', DateTime.now().millisecondsSinceEpoch);
    // Also update legacy daily spin key for backward compatibility
    await _prefs.setString('last_daily_spin_date', getTodayUtcDateString());
  }

  // ==========================================
  // DAILY PUZZLE CALENDAR & MILESTONE TRACKER
  // ==========================================
  String getTodayUtcDateString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String getYesterdayUtcDateString() {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  /// Returns 'won', 'passed', or null
  String? getDailyStatus(String dateString) {
    final status = _prefs.getString('daily_status_$dateString');
    if (status != null) return status;
    if (_prefs.getBool('daily_$dateString') == true) return 'won';
    return null;
  }

  bool isDailyWon(String dateString) => getDailyStatus(dateString) == 'won';
  bool isDailyPassed(String dateString) => getDailyStatus(dateString) == 'passed';

  bool isDailyCompleted(String dateString) {
    return getDailyStatus(dateString) != null;
  }

  bool get isDailyCompletedToday {
    return isDailyCompleted(getTodayUtcDateString());
  }

  int get monthlyDailyWins {
    final now = DateTime.now().toUtc();
    final monthKey = 'monthly_daily_wins_${now.year}_${now.month.toString().padLeft(2, '0')}';
    return _prefs.getInt(monthKey) ?? _prefs.getInt('monthly_daily_wins') ?? 0;
  }

  Future<void> recordDailyWin(String dateString) async {
    await _prefs.setBool('daily_$dateString', true);
    await _prefs.setString('daily_status_$dateString', 'won');

    // Update daily streak
    final yesterday = getYesterdayUtcDateString();
    final lastDaily = _prefs.getString('last_daily_date');
    final currentDailyStreak = dailyStreak;

    if (lastDaily == yesterday) {
      await _prefs.setInt('daily_streak', currentDailyStreak + 1);
    } else if (lastDaily != dateString) {
      await _prefs.setInt('daily_streak', 1);
    }
    await _prefs.setString('last_daily_date', dateString);

    // Update monthly wins count
    final now = DateTime.now().toUtc();
    final monthKey = 'monthly_daily_wins_${now.year}_${now.month.toString().padLeft(2, '0')}';
    final currentWins = monthlyDailyWins + 1;
    await _prefs.setInt(monthKey, currentWins);
    await _prefs.setInt('monthly_daily_wins', currentWins);
  }

  Future<void> recordDailyPass(String dateString) async {
    await _prefs.setBool('daily_$dateString', true);
    await _prefs.setString('daily_status_$dateString', 'passed');
  }

  int get dailyStreak => _prefs.getInt('daily_streak') ?? 0;

  bool isMilestoneClaimed(int milestoneTarget) {
    final now = DateTime.now().toUtc();
    final key = 'milestone_claimed_${now.year}_${now.month.toString().padLeft(2, '0')}_$milestoneTarget';
    return _prefs.getBool(key) ?? false;
  }

  Future<bool> claimMilestoneChest(int milestoneTarget, int coinBonus) async {
    if (isMilestoneClaimed(milestoneTarget)) return false;
    if (monthlyDailyWins < milestoneTarget) return false;

    final now = DateTime.now().toUtc();
    final key = 'milestone_claimed_${now.year}_${now.month.toString().padLeft(2, '0')}_$milestoneTarget';
    await _prefs.setBool(key, true);
    await addCoins(coinBonus);
    return true;
  }

  // ==========================================
  // LEVEL & XP
  // ==========================================
  int get xp => _prefs.getInt('player_xp') ?? 0;
  int get playerLevel => (xp ~/ 100) + 1;

  Future<void> addXp(int amount) async {
    await _prefs.setInt('player_xp', xp + amount);
  }

  // ==========================================
  // PIGGY BANK
  // ==========================================
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

  // ==========================================
  // SETTINGS & AUDIO
  // ==========================================
  bool get isSoundEnabled => _prefs.getBool('sound_enabled') ?? true;

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }

  int get wordLength => _prefs.getInt('word_length_preference') ?? 5;

  Future<void> setWordLength(int length) async {
    await _prefs.setInt('word_length_preference', length);
  }

  // ==========================================
  // OVERALL STATISTICS
  // ==========================================
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
}
