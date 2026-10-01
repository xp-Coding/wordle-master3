import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/logic/wordle_evaluator.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/dictionary_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/animated_flip_tile.dart';
import '../widgets/booster_bar.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/shake_widget.dart';
import '../widgets/win_loss_modal.dart';

class ClassicWordleScreen extends StatefulWidget {
  final int initialWordLength;

  const ClassicWordleScreen({
    super.key,
    this.initialWordLength = 5,
  });

  @override
  State<ClassicWordleScreen> createState() => _ClassicWordleScreenState();
}

class _ClassicWordleScreenState extends State<ClassicWordleScreen> {
  final AudioService _audio = AudioService();
  final DictionaryService _dict = DictionaryService();
  final StorageService _storage = StorageService();

  late int _wordLength;
  late String _targetWord;

  static const int _maxAttempts = 6;
  int _currentAttempt = 0;
  String _currentGuess = '';

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
    _wordLength = widget.initialWordLength;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _targetWord = _dict.getRandomSolution(_wordLength);
      _currentAttempt = 0;
      _currentGuess = '';
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

  Future<void> _onEnterTapped() async {
    if (_isGameOver) return;

    if (_currentGuess.length < _wordLength) {
      _triggerRowError('Word too short');
      return;
    }

    if (!_dict.isValidWord(_currentGuess)) {
      _triggerRowError('Not in word list');
      return;
    }

    // Evaluate using strict Two-Pass algorithm
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
        continue; // Keep Green
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
        margin: const EdgeInsets.only(bottom: 120, left: 60, right: 60),
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
    await _storage.addCoins(30);

    // Stagger delay before confetti and modal
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
        coinsEarned: isWin ? 30 : 5,
        currentStreak: _storage.currentStreak,
        attemptsUsed: _currentAttempt + 1,
        onNextWord: () {
          Navigator.of(ctx).pop();
          _startNewGame();
        },
        onMainMenu: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Booster Actions
  Future<void> _useHintBooster() async {
    if (_isGameOver) return;
    final success = await _storage.deductCoins(50);
    if (!success) return;

    _audio.playSfx(GameSfx.booster);

    // Reveal the first missing green letter
    for (int i = 0; i < _wordLength; i++) {
      final targetChar = _targetWord[i];
      if (_currentGuess.length <= i) {
        setState(() {
          _currentGuess += targetChar;
          _gridEvaluations[_currentAttempt][i] = LetterEvaluation(
            char: targetChar,
            state: LetterState.filled,
          );
        });
        break;
      }
    }
  }

  Future<void> _useCrosshairBooster() async {
    if (_isGameOver) return;
    final success = await _storage.deductCoins(30);
    if (!success) return;

    _audio.playSfx(GameSfx.booster);

    // Pick 3 letters not in target word and not already eliminated
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final candidateLetters = allLetters.split('').where((char) {
      return !_targetWord.contains(char) && !_eliminatedKeys.contains(char);
    }).toList()
      ..shuffle();

    setState(() {
      _eliminatedKeys.addAll(candidateLetters.take(3));
    });
  }

  void _useSkipBooster() {
    if (_isGameOver) return;
    _audio.playSfx(GameSfx.booster);
    _startNewGame();
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
                  Expanded(
                    child: Center(
                      child: _buildGrid(),
                    ),
                  ),
                  BoosterBar(
                    userCoins: _storage.coins,
                    onHintTapped: _useHintBooster,
                    onCrosshairTapped: _useCrosshairBooster,
                    onSkipTapped: _useSkipBooster,
                  ),
                  GameKeyboard(
                    keyStates: _keyboardStates,
                    eliminatedKeys: _eliminatedKeys,
                    onKeyTapped: _onKeyTapped,
                    onEnterTapped: _onEnterTapped,
                    onDeleteTapped: _onDeleteTapped,
                  ),
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
          Text(
            'WORDLE ($_wordLength LETTERS)',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppColors.textLight,
            ),
          ),
          Row(
            children: [
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
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = (screenWidth * 0.90).clamp(280.0, 420.0);
    final tileSize = (gridWidth / _wordLength) - 8;

    return Container(
      width: gridWidth,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_maxAttempts, (rowIdx) {
          final isWinningRow = _isWinningRow && rowIdx == _currentAttempt;

          return ShakeWidget(
            controller: _shakeControllers[rowIdx],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_wordLength, (colIdx) {
                final evaluation = _gridEvaluations[rowIdx][colIdx];
                return SizedBox(
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
          );
        }),
      ),
    );
  }
}
