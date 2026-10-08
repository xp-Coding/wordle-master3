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
import '../widgets/game_keyboard.dart';
import '../widgets/shake_widget.dart';
import '../widgets/win_loss_modal.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  final AudioService _audio = AudioService();
  final WordDictionary _dict = WordDictionary();
  final GameStorage _storage = GameStorage();

  static const int _wordLength = 5;
  static const int _maxAttempts = 6;

  late DateTime _todayUtc;
  late String _todayKey;
  late String _targetWord;

  int _currentAttempt = 0;
  String _currentGuess = '';
  bool _isGameOver = false;
  bool _isWinningRow = false;
  bool _isAlreadyCompletedToday = false;

  late List<List<LetterEvaluation>> _gridEvaluations;
  late List<bool> _revealedRows;
  late List<ShakeController> _shakeControllers;
  final Map<String, LetterState> _keyboardStates = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _todayUtc = DateTime.now().toUtc();
    _todayKey = _storage.getTodayUtcDateString();
    _targetWord = _dict.getDailyWord(_todayUtc);

    _isAlreadyCompletedToday = _storage.isDailyCompletedToday;

    _gridEvaluations = List.generate(
      _maxAttempts,
      (_) => List.generate(
        _wordLength,
        (_) => const LetterEvaluation(char: '', state: LetterState.empty),
      ),
    );
    _revealedRows = List.generate(_maxAttempts, (_) => false);
    _shakeControllers = List.generate(_maxAttempts, (_) => ShakeController());

    if (_isAlreadyCompletedToday) {
      _isGameOver = true;
      // Pre-fill first row with solution in green as completed badge
      _revealedRows[0] = true;
      _gridEvaluations[0] = List.generate(
        _wordLength,
        (i) => LetterEvaluation(char: _targetWord[i], state: LetterState.correct),
      );
    }
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
      if (existingState == LetterState.correct) continue;
      if (eval.state == LetterState.correct ||
          (eval.state == LetterState.misplaced && existingState != LetterState.correct)) {
        _keyboardStates[eval.char] = eval.state;
      } else if (existingState == null) {
        _keyboardStates[eval.char] = eval.state;
      }
    }

    final hasWon = WordleEvaluator.isWin(evaluations);

    if (hasWon) {
      setState(() {
        _isGameOver = true;
        _isWinningRow = true;
      });
      await _storage.recordDailyWin(_todayKey);
      await _storage.addCoins(100);
      await _storage.addXp(50);

      await Future.delayed(const Duration(milliseconds: 700));
      _audio.playSfx(GameSfx.win);
      _confettiController.play();

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;

      _showResultModal(isWin: true);
    } else {
      if (_currentAttempt + 1 >= _maxAttempts) {
        setState(() {
          _isGameOver = true;
        });
        await _storage.recordDailyWin(_todayKey);
        _audio.playSfx(GameSfx.strike);
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted) return;
        _showResultModal(isWin: false);
      } else {
        setState(() {
          _currentAttempt++;
          _currentGuess = '';
        });
      }
    }
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

  void _showResultModal({required bool isWin}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WinLossModal(
        isWin: isWin,
        solution: _targetWord,
        coinsEarned: isWin ? 100 : 10,
        currentStreak: _storage.dailyStreak,
        attemptsUsed: _currentAttempt + 1,
        onNextWord: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
        onMainMenu: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _claimMilestone(int targetWins, int coinBonus) async {
    final success = await _storage.claimMilestoneChest(targetWins, coinBonus);
    if (success) {
      _audio.playSfx(GameSfx.win);
      _confettiController.play();
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Milestone Chest Unlocked: +$coinBonus Coins!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.tileCorrect,
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
                  _buildHeader(),
                  _buildOctoberCalendarCard(),
                  _buildMilestoneChestsBar(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _isAlreadyCompletedToday
                            ? _buildCompletedBadgeView()
                            : _buildGrid(),
                      ),
                    ),
                  ),
                  if (!_isAlreadyCompletedToday) ...[
                    _buildDedicatedSubmitRow(),
                    GameKeyboard(
                      keyStates: _keyboardStates,
                      onKeyTapped: _onKeyTapped,
                      onEnterTapped: _onSubmitTapped,
                      onDeleteTapped: _onDeleteTapped,
                    ),
                  ],
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
                'DAILY PUZZLE',
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

  /// October 2026 Production Calendar Grid
  Widget _buildOctoberCalendarCard() {
    const daysInMonth = 31;
    // October 1, 2026 was a Thursday (weekday index 4 where Mon=1, Sun=7)
    // Leading empty days in Monday-first calendar = 3 (Mon, Tue, Wed)
    const firstWeekdayOffset = 3;
    final currentDay = _todayUtc.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.gameHeaderBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tileFilledBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OCTOBER 2026',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.coinGold,
                ),
              ),
              Text(
                '${_storage.monthlyDailyWins}/$daysInMonth Wins',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Day initials header (M T W T F S S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return SizedBox(
                width: 24,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          // Days grid (up to 35 cells for 5 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekdayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final dateStr = '2026-10-${dayNumber.toString().padLeft(2, '0')}';
              final isCompleted = _storage.isDailyCompleted(dateStr);
              final isCurrent = dayNumber == currentDay;
              final isFuture = dayNumber > currentDay;

              Color bgColor;
              Color textColor = Colors.white;

              if (isCompleted) {
                bgColor = AppColors.tileCorrect;
              } else if (isCurrent) {
                bgColor = AppColors.streakOrange.withValues(alpha: 0.6);
              } else if (isFuture) {
                bgColor = AppColors.tileEmpty.withValues(alpha: 0.3);
                textColor = Colors.white38;
              } else {
                bgColor = AppColors.tileFilled;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(5),
                  border: isCurrent
                      ? Border.all(color: AppColors.streakOrange, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : Text(
                        '$dayNumber',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Milestone Chest Tracker (3 Wins Bronze, 10 Wins Silver, 31 Wins Gold)
  Widget _buildMilestoneChestsBar() {
    final wins = _storage.monthlyDailyWins;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tileFilled.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMilestoneChestItem(
            label: '3 WINS',
            bonus: 150,
            targetWins: 3,
            currentWins: wins,
            color: const Color(0xFFCD7F32), // Bronze
            icon: Icons.shield_rounded,
          ),
          _buildMilestoneChestItem(
            label: '10 WINS',
            bonus: 350,
            targetWins: 10,
            currentWins: wins,
            color: const Color(0xFFC0C0C0), // Silver
            icon: Icons.military_tech_rounded,
          ),
          _buildMilestoneChestItem(
            label: '31 WINS',
            bonus: 1000,
            targetWins: 31,
            currentWins: wins,
            color: AppColors.coinGold, // Gold
            icon: Icons.workspace_premium_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneChestItem({
    required String label,
    required int bonus,
    required int targetWins,
    required int currentWins,
    required Color color,
    required IconData icon,
  }) {
    final isReached = currentWins >= targetWins;
    final isClaimed = _storage.isMilestoneClaimed(targetWins);

    return InkWell(
      onTap: (isReached && !isClaimed) ? () => _claimMilestone(targetWins, bonus) : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isReached ? color : AppColors.tileAbsent,
                ),
                if (isClaimed)
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isReached ? color : AppColors.textMuted,
              ),
            ),
            Text(
              isClaimed ? 'CLAIMED' : (isReached ? 'TAP TO CLAIM!' : '+$bonus'),
              style: GoogleFonts.outfit(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: isReached && !isClaimed ? Colors.greenAccent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBadgeView() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gameHeaderBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tileCorrect, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 52),
          const SizedBox(height: 12),
          Text(
            'TODAY\'S PUZZLE COMPLETED!',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Word: $_targetWord',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: AppColors.coinGold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Come back tomorrow for a new global daily challenge!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textMuted,
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
        height: 40,
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
                'SUBMIT DAILY GUESS',
                style: GoogleFonts.outfit(
                  fontSize: 13,
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
    final gridWidth = (screenWidth * 0.90).clamp(260.0, 380.0);
    final tileSize = ((gridWidth - (_wordLength * 6)) / _wordLength).clamp(38.0, 58.0);

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
              padding: const EdgeInsets.symmetric(vertical: 2.5),
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
