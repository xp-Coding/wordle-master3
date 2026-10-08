import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/classic_levels.dart';
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

class ClassicWordleScreen extends StatefulWidget {
  final int? initialLevel;

  const ClassicWordleScreen({
    super.key,
    this.initialLevel,
  });

  @override
  State<ClassicWordleScreen> createState() => _ClassicWordleScreenState();
}

class _ClassicWordleScreenState extends State<ClassicWordleScreen> {
  final AudioService _audio = AudioService();
  final WordDictionary _dict = WordDictionary();
  final GameStorage _storage = GameStorage();
  final AdService _adService = AdService();

  late int _currentLevelNumber;
  late ClassicLevel _currentLevel;
  late String _targetWord;
  late int _wordLength;

  static const int _maxAttempts = 6;
  int _currentAttempt = 0;
  String _currentGuess = '';
  int _hintsUsedInLevel = 0;

  // Grid state: 6 rows of evaluations
  late List<List<LetterEvaluation>> _gridEvaluations;
  late List<bool> _revealedRows;
  late List<ShakeController> _shakeControllers;
  bool _isWinningRow = false;
  bool _isGameOver = false;

  // Keyboard and boosters state
  final Map<String, LetterState> _keyboardStates = {};
  final Set<String> _eliminatedKeys = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.initialLevel ?? _storage.classicLevel;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startLevel(_currentLevelNumber);
  }

  void _startLevel(int levelNum) {
    setState(() {
      _currentLevelNumber = levelNum.clamp(1, 50);
      _currentLevel = ClassicLevels.getLevel(_currentLevelNumber);
      _targetWord = _currentLevel.targetWord;
      _wordLength = _targetWord.length;

      _currentAttempt = 0;
      _currentGuess = '';
      _hintsUsedInLevel = 0;
      _isGameOver = false;
      _isWinningRow = false;
      _keyboardStates.clear();
      _eliminatedKeys.clear();

      _gridEvaluations = List.generate(
        _maxAttempts,
        (_) => List.generate(
          _wordLength,
          (_) => const LetterEvaluation(char: '', state: LetterState.empty),
        ),
      );

      _revealedRows = List.generate(_maxAttempts, (_) => false);
      _shakeControllers = List.generate(_maxAttempts, (_) => ShakeController());
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onKeyTapped(String char) {
    if (_isGameOver) return;
    if (_currentGuess.length >= _wordLength) return;

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

    // Two-Pass Wordle Validation Engine
    final evaluations = WordleEvaluator.evaluate(
      guess: _currentGuess,
      target: _targetWord,
    );

    final rowIdx = _currentAttempt;

    setState(() {
      _gridEvaluations[rowIdx] = evaluations;
      _revealedRows[rowIdx] = true;
    });

    // Staggered flip sound
    for (int i = 0; i < _wordLength; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        _audio.playSfx(GameSfx.flip);
      });
    }

    // Update keyboard states
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

    final hasWon = WordleEvaluator.isWin(evaluations);

    if (hasWon) {
      _handleVictory();
    } else {
      if (_currentAttempt + 1 >= _maxAttempts) {
        _handleDefeat();
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

  Future<void> _handleVictory() async {
    setState(() {
      _isGameOver = true;
      _isWinningRow = true;
    });

    await _storage.recordGameResult(won: true);
    await _storage.addCoins(35);
    await _storage.advanceClassicLevel();

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

    await _storage.recordGameResult(won: false);
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
        coinsEarned: isWin ? 35 : 5,
        currentStreak: _storage.currentStreak,
        attemptsUsed: _currentAttempt + 1,
        onNextWord: () {
          Navigator.of(ctx).pop();
          if (isWin) {
            _startLevel(_currentLevelNumber + 1);
          } else {
            _startLevel(_currentLevelNumber);
          }
        },
        onMainMenu: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================
  // POSITIONAL HINT & BOOSTER ACTIONS
  // ==========================================
  Future<void> _useHintBooster() async {
    if (_isGameOver) return;

    // Strict limit: cannot exceed word length
    if (_hintsUsedInLevel >= _wordLength) {
      _triggerRowError('Max hints reached for this level');
      return;
    }

    // Always require ad viewing before activating skill
    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Classic Mode Positional Hint',
      onRewardGranted: () {},
    );
    if (!watched) return;

    _audio.playSfx(GameSfx.booster);

    // Place the exact correct letter into its real position in the active guess row
    final targetChars = _targetWord.split('');
    final guessChars = _currentGuess.padRight(_wordLength, ' ').split('');

    int targetSlot = -1;
    for (int i = 0; i < _wordLength; i++) {
      if (guessChars[i] != targetChars[i]) {
        targetSlot = i;
        break;
      }
    }

    if (targetSlot == -1) {
      targetSlot = 0;
    }

    // Place target letter into real position
    guessChars[targetSlot] = targetChars[targetSlot];
    final updatedGuess = guessChars.join('').trimRight();

    setState(() {
      _hintsUsedInLevel++;
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

    // Always require ad viewing before activating skill
    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Classic Mode Crosshair',
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

  Future<void> _useSkipBooster() async {
    if (_isGameOver) return;

    // Always require ad viewing before activating skill
    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Classic Mode Pass',
      onRewardGranted: () {},
    );
    if (!watched) return;

    _audio.playSfx(GameSfx.booster);
    await _storage.advanceClassicLevel();
    _startLevel(_currentLevelNumber + 1);
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
                  _buildHeaderHUD(),
                  _buildEmojiCluesBar(),
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
                    onSkipTapped: _useSkipBooster,
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

              // Confetti burst on victory
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.amber,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.gameHeaderBg.withValues(alpha: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textLight),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            children: [
              Text(
                'LEVEL $_currentLevelNumber',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '$_wordLength LETTERS • HINTS: $_hintsUsedInLevel/$_wordLength',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.menuWarmAmber,
                  letterSpacing: 0.8,
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

  /// Emoji clues bar matching Lion Studios casual-gaming polish
  Widget _buildEmojiCluesBar() {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tileFilled.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tileFilledBorder.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CLUES:',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          ..._currentLevel.emojiClues.map(
            (emoji) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Prominent, tactile dedicated SUBMIT button alongside QWERTY controls
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
