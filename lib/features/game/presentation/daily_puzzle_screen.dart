import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/word_dictionary.dart';
import '../../../core/logic/wordle_evaluator.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/animated_flip_tile.dart';
import '../widgets/booster_bar.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/shake_widget.dart';
import '../widgets/win_loss_modal.dart';

/// Production Daily Puzzle Calendar Dashboard & Hub
/// Features October 2026 progress bar, milestone grand prizes, full calendar grid,
/// and dedicated play button to launch the day's challenge.
class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  final GameStorage _storage = GameStorage();
  final AudioService _audio = AudioService();

  late DateTime _todayUtc;
  late String _todayKey;

  @override
  void initState() {
    super.initState();
    _todayUtc = DateTime.now().toUtc();
    _todayKey = _storage.getTodayUtcDateString();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _claimMilestone(int target, int reward) async {
    _audio.playSfx(GameSfx.click);
    final success = await _storage.claimMilestoneChest(target, reward);
    if (success) {
      _audio.playSfx(GameSfx.win);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Claimed Grand Prize: +$reward Coins!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.tileCorrect,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refresh();
      }
    }
  }

  void _openDailyGame() {
    _audio.playSfx(GameSfx.click);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => DailyWordlePlayScreen(
              targetDateUtc: _todayUtc,
              dateKey: _todayKey,
            ),
          ),
        )
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBgGradientStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gameBgGradientStart, AppColors.gameBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _buildMonthlyProgressCard(),
                      const SizedBox(height: 12),
                      _buildOctoberCalendarCard(),
                      const SizedBox(height: 14),
                      _buildPlayButtonSection(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const AdBannerContainer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            children: [
              Text(
                'DAILY PUZZLE HUB',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              Text(
                '$_todayKey (UTC)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.menuWarmAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tileFilled,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.streakOrange.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.streakOrange, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_storage.dailyStreak}d',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.streakOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Monthly Progress Card with Progress Bar and Grand Prizes
  Widget _buildMonthlyProgressCard() {
    const totalDays = 31;
    final currentWins = _storage.monthlyDailyWins;
    final progressFraction = (currentWins / totalDays).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gameHeaderBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.coinGold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'OCTOBER PROGRESS',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentWins / $totalDays Wins',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coinGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 16,
              child: Stack(
                children: [
                  Container(color: AppColors.tileFilled),
                  FractionallySizedBox(
                    widthFactor: progressFraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFF10B981)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Grand Prizes Milestone Chests Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMilestonePrize(
                milestone: 3,
                reward: 100,
                title: '3 WINS',
                badgeName: 'BRONZE',
                badgeColor: const Color(0xFFCD7F32),
                icon: Icons.star_rounded,
                isUnlocked: currentWins >= 3,
                isClaimed: _storage.isMilestoneClaimed(3),
                onClaim: () => _claimMilestone(3, 100),
              ),
              _buildMilestonePrize(
                milestone: 10,
                reward: 250,
                title: '10 WINS',
                badgeName: 'SILVER',
                badgeColor: const Color(0xFFC0C0C0),
                icon: Icons.military_tech_rounded,
                isUnlocked: currentWins >= 10,
                isClaimed: _storage.isMilestoneClaimed(10),
                onClaim: () => _claimMilestone(10, 250),
              ),
              _buildMilestonePrize(
                milestone: 31,
                reward: 1000,
                title: '31 WINS',
                badgeName: 'GRAND PRIZE',
                badgeColor: AppColors.coinGold,
                icon: Icons.workspace_premium_rounded,
                isUnlocked: currentWins >= 31,
                isClaimed: _storage.isMilestoneClaimed(31),
                onClaim: () => _claimMilestone(31, 1000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonePrize({
    required int milestone,
    required int reward,
    required String title,
    required String badgeName,
    required Color badgeColor,
    required IconData icon,
    required bool isUnlocked,
    required bool isClaimed,
    required VoidCallback onClaim,
  }) {
    return GestureDetector(
      onTap: isUnlocked && !isClaimed ? onClaim : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isClaimed
              ? AppColors.tileFilled.withValues(alpha: 0.5)
              : (isUnlocked
                  ? badgeColor.withValues(alpha: 0.2)
                  : Colors.black26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isClaimed
                ? Colors.white24
                : (isUnlocked ? badgeColor : Colors.white12),
            width: isUnlocked && !isClaimed ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: isClaimed ? Colors.white38 : (isUnlocked ? badgeColor : Colors.white24),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              '+$reward COINS',
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? AppColors.coinGold : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isClaimed
                    ? Colors.white12
                    : (isUnlocked ? AppColors.tileCorrect : Colors.black38),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isClaimed ? 'CLAIMED' : (isUnlocked ? 'CLAIM!' : 'LOCKED'),
                style: GoogleFonts.outfit(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// October 2026 Production Calendar Grid
  Widget _buildOctoberCalendarCard() {
    const daysInMonth = 31;
    // October 1, 2026 was a Thursday (weekday index 4 where Mon=1, Sun=7)
    // Offset in Monday-first calendar = 3 (Mon, Tue, Wed empty)
    const firstWeekdayOffset = 3;
    final currentDay = _todayUtc.day;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gameHeaderBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileFilledBorder.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OCTOBER 2026 CALENDAR',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.coinGold,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Won', AppColors.tileCorrect),
                  const SizedBox(width: 8),
                  _buildLegendItem('Passed', AppColors.streakOrange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Day initials header (M T W T F S S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 28,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          // Days grid (up to 35 cells)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekdayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final dateStr = '2026-10-${dayNumber.toString().padLeft(2, '0')}';
              final isWon = _storage.isDailyWon(dateStr);
              final isPassed = _storage.isDailyPassed(dateStr);
              final isCurrent = dayNumber == currentDay;
              final isFuture = dayNumber > currentDay;

              Color bgColor;
              Color borderColor = Colors.transparent;
              Widget statusWidget = Text(
                '$dayNumber',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              );

              if (isWon) {
                bgColor = AppColors.tileCorrect;
                statusWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.coinGold),
                  ],
                );
              } else if (isPassed) {
                bgColor = AppColors.streakOrange.withValues(alpha: 0.85);
                statusWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Icon(Icons.skip_next_rounded, size: 14, color: Colors.white),
                  ],
                );
              } else if (isCurrent) {
                bgColor = AppColors.tileFilled;
                borderColor = AppColors.coinGold;
              } else if (isFuture) {
                bgColor = Colors.black26;
                statusWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.white30),
                    ),
                    const Icon(Icons.lock_rounded, size: 10, color: Colors.white24),
                  ],
                );
              } else {
                // Past unplayed day
                bgColor = AppColors.tileEmpty;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? AppColors.coinGold : borderColor,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: statusWidget,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  /// Dedicated Play Button for Today's Puzzle
  Widget _buildPlayButtonSection() {
    final isWonToday = _storage.isDailyWon(_todayKey);
    final isPassedToday = _storage.isDailyPassed(_todayKey);

    String buttonLabel = 'PLAY TODAY\'S PUZZLE (OCT ${_todayUtc.day})';
    Color buttonColor = AppColors.tileCorrect;
    IconData buttonIcon = Icons.play_arrow_rounded;

    if (isWonToday) {
      buttonLabel = 'TODAY\'S PUZZLE SOLVED! ⭐';
      buttonColor = const Color(0xFF538D4E);
      buttonIcon = Icons.check_circle_rounded;
    } else if (isPassedToday) {
      buttonLabel = 'TODAY\'S PUZZLE PASSED ⏭️ (RETRY)';
      buttonColor = AppColors.streakOrange;
      buttonIcon = Icons.refresh_rounded;
    }

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _openDailyGame,
        icon: Icon(buttonIcon, color: Colors.white, size: 24),
        label: Text(
          buttonLabel,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

/// =======================================================================
/// Actual Daily Wordle Gameplay Screen (Launched by Play button)
/// Includes Hint, Crosshair, and Pass (all watching ads first!)
/// =======================================================================
class DailyWordlePlayScreen extends StatefulWidget {
  final DateTime targetDateUtc;
  final String dateKey;

  const DailyWordlePlayScreen({
    super.key,
    required this.targetDateUtc,
    required this.dateKey,
  });

  @override
  State<DailyWordlePlayScreen> createState() => _DailyWordlePlayScreenState();
}

class _DailyWordlePlayScreenState extends State<DailyWordlePlayScreen> {
  final AudioService _audio = AudioService();
  final WordDictionary _dict = WordDictionary();
  final GameStorage _storage = GameStorage();
  final AdService _adService = AdService();

  static const int _wordLength = 5;
  static const int _maxAttempts = 6;

  late String _targetWord;
  int _currentAttempt = 0;
  String _currentGuess = '';
  bool _isGameOver = false;
  bool _isWinningRow = false;

  late List<List<LetterEvaluation>> _gridEvaluations;
  late List<bool> _revealedRows;
  late List<ShakeController> _shakeControllers;
  final Map<String, LetterState> _keyboardStates = {};
  final Set<String> _eliminatedKeys = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _targetWord = _dict.getDailyWord(widget.targetDateUtc);

    _gridEvaluations = List.generate(
      _maxAttempts,
      (_) => List.generate(
        _wordLength,
        (_) => const LetterEvaluation(char: '', state: LetterState.empty),
      ),
    );
    _revealedRows = List.generate(_maxAttempts, (_) => false);
    _shakeControllers = List.generate(_maxAttempts, (_) => ShakeController());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onKeyTapped(String char) {
    if (_isGameOver || _currentGuess.length >= _wordLength) return;
    _audio.playSfx(GameSfx.click);
    setState(() {
      _currentGuess += char;
      final colIndex = _currentGuess.length - 1;
      _gridEvaluations[_currentAttempt][colIndex] = LetterEvaluation(
        char: char,
        state: LetterState.filled,
      );
    });
  }

  void _onDeleteTapped() {
    if (_isGameOver || _currentGuess.isEmpty) return;
    _audio.playSfx(GameSfx.click);
    setState(() {
      final colIndex = _currentGuess.length - 1;
      _gridEvaluations[_currentAttempt][colIndex] = const LetterEvaluation(
        char: '',
        state: LetterState.empty,
      );
      _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
    });
  }

  Future<void> _onSubmitTapped() async {
    if (_isGameOver) return;

    if (_currentGuess.length < _wordLength) {
      _triggerRowError('Word too short');
      return;
    }

    if (!_dict.isValidWord(_currentGuess)) {
      _triggerRowError('Not in word list');
      return;
    }

    final evaluations = WordleEvaluator.evaluate(
      guess: _currentGuess,
      target: _targetWord,
    );

    final rowIdx = _currentAttempt;

    setState(() {
      _gridEvaluations[rowIdx] = evaluations;
      _revealedRows[rowIdx] = true;
    });

    for (int i = 0; i < _wordLength; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        _audio.playSfx(GameSfx.flip);
      });
    }

    for (final eval in evaluations) {
      final existingState = _keyboardStates[eval.char];
      if (existingState == LetterState.correct) {
        continue;
      }
      if (eval.state == LetterState.correct ||
          (eval.state == LetterState.misplaced && existingState != LetterState.correct)) {
        _keyboardStates[eval.char] = eval.state;
      } else if (existingState == null) {
        _keyboardStates[eval.char] = eval.state;
      }
    }

    if (_currentGuess == _targetWord) {
      await _handleVictory();
      return;
    }

    if (_currentAttempt >= _maxAttempts - 1) {
      await _handleDefeat();
      return;
    }

    setState(() {
      _currentAttempt++;
      _currentGuess = '';
    });
  }

  void _triggerRowError(String message) {
    _audio.playSfx(GameSfx.error);
    _shakeControllers[_currentAttempt].shake();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 160, left: 60, right: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleVictory() async {
    setState(() {
      _isGameOver = true;
      _isWinningRow = true;
    });

    await _storage.recordDailyWin(widget.dateKey);
    await _storage.addCoins(50);

    await Future.delayed(Duration(milliseconds: _wordLength * 80 + 300));
    _audio.playSfx(GameSfx.win);
    _confettiController.play();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    _showResultModal(isWin: true);
  }

  Future<void> _handleDefeat() async {
    setState(() {
      _isGameOver = true;
    });

    _audio.playSfx(GameSfx.strike);
    await Future.delayed(Duration(milliseconds: _wordLength * 80 + 500));
    if (!mounted) return;

    _showResultModal(isWin: false);
  }

  void _showResultModal({required bool isWin}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WinLossModal(
        isWin: isWin,
        solution: _targetWord,
        coinsEarned: isWin ? 50 : 10,
        currentStreak: _storage.dailyStreak,
        attemptsUsed: _currentAttempt + 1,
        onNextWord: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop(); // Return to dashboard
        },
        onMainMenu: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================
  // SKILLS & BOOSTERS (All viewing ads first!)
  // ==========================================
  Future<void> _useHintBooster() async {
    if (_isGameOver) return;

    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Daily Puzzle Positional Hint',
      onRewardGranted: () {},
    );
    if (!watched) return;

    _audio.playSfx(GameSfx.booster);
    final targetChars = _targetWord.split('');
    final guessChars = _currentGuess.padRight(_wordLength, ' ').split('');

    int targetSlot = 0;
    for (int i = 0; i < _wordLength; i++) {
      if (guessChars[i] != targetChars[i]) {
        targetSlot = i;
        break;
      }
    }

    guessChars[targetSlot] = targetChars[targetSlot];
    final updatedGuess = guessChars.join('').trimRight();

    setState(() {
      _currentGuess = updatedGuess;
      for (int i = 0; i < _wordLength; i++) {
        final char = i < _currentGuess.length ? _currentGuess[i] : '';
        _gridEvaluations[_currentAttempt][i] = LetterEvaluation(
          char: char,
          state: char.isNotEmpty ? LetterState.filled : LetterState.empty,
        );
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hint placed letter "${targetChars[targetSlot]}" at slot ${targetSlot + 1}!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.boosterHint,
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 160, left: 40, right: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _useCrosshairBooster() async {
    if (_isGameOver) return;

    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Daily Puzzle Crosshair',
      onRewardGranted: () {},
    );
    if (!watched) return;

    _audio.playSfx(GameSfx.booster);
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final candidateLetters = allLetters.split('').where((char) {
      return !_targetWord.contains(char) && !_eliminatedKeys.contains(char);
    }).toList()
      ..shuffle();

    setState(() {
      _eliminatedKeys.addAll(candidateLetters.take(3));
    });
  }

  Future<void> _usePassBooster() async {
    if (_isGameOver) return;

    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Daily Puzzle Pass',
      onRewardGranted: () {},
    );
    if (!watched) return;

    _audio.playSfx(GameSfx.booster);

    // Record as passed for this specific day
    await _storage.recordDailyPass(widget.dateKey);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF13192B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.streakOrange, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.skip_next_rounded, size: 52, color: AppColors.streakOrange),
                const SizedBox(height: 12),
                Text(
                  'DAILY PUZZLE PASSED',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The answer was: $_targetWord\nThis day is now marked as PASSED on your calendar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textLight),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(); // Return to dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.streakOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'BACK TO CALENDAR',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameBgGradientStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gameBgGradientStart, AppColors.gameBgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildGameHeader(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildGrid(),
                      ),
                    ),
                  ),
                  BoosterBar(
                    userCoins: _storage.coins,
                    onHintTapped: _useHintBooster,
                    onCrosshairTapped: _useCrosshairBooster,
                    onSkipTapped: _usePassBooster,
                  ),
                  _buildDedicatedSubmitRow(),
                  GameKeyboard(
                    keyStates: _keyboardStates,
                    eliminatedKeys: _eliminatedKeys,
                    onKeyTapped: _onKeyTapped,
                    onEnterTapped: _onSubmitTapped,
                    onDeleteTapped: _onDeleteTapped,
                  ),
                  const AdBannerContainer(),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.gameHeaderBg.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            children: [
              Text(
                'DAILY PUZZLE',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.dateKey} (UTC)',
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.menuWarmAmber,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tileFilled,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_storage.coins}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coinGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDedicatedSubmitRow() {
    final canSubmit = _currentGuess.length == _wordLength && !_isGameOver;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: ElevatedButton(
          onPressed: canSubmit ? _onSubmitTapped : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tileCorrect,
            disabledBackgroundColor: AppColors.tileFilled.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: canSubmit ? AppColors.tileCorrectBevel : Colors.transparent,
                width: 1.5,
              ),
            ),
            elevation: canSubmit ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: canSubmit ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'SUBMIT GUESS (${_currentGuess.length}/$_wordLength)',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: canSubmit ? Colors.white : AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = (screenWidth * 0.90).clamp(260.0, 400.0);
    final tileSize = ((gridWidth - (_wordLength * 6)) / _wordLength).clamp(38.0, 62.0);

    return Container(
      width: gridWidth,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_maxAttempts, (rowIdx) {
          final isWinningRow = _isWinningRow && rowIdx == _currentAttempt;

          return ShakeWidget(
            controller: _shakeControllers[rowIdx],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_wordLength, (colIdx) {
                  final evaluation = _gridEvaluations[rowIdx][colIdx];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: tileSize,
                    height: tileSize,
                    child: AnimatedFlipTile(
                      letter: evaluation.char,
                      state: evaluation.state,
                      columnIndex: colIdx,
                      isRevealed: _revealedRows[rowIdx],
                      isWinningBounce: isWinningRow,
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}
