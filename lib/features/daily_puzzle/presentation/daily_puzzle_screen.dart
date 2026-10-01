import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/logic/wordle_evaluator.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/dictionary_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../game/widgets/animated_flip_tile.dart';
import '../../game/widgets/game_keyboard.dart';
import '../../game/widgets/shake_widget.dart';
import '../../game/widgets/win_loss_modal.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  final AudioService _audio = AudioService();
  final DictionaryService _dict = DictionaryService();
  final StorageService _storage = StorageService();

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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Seeded puzzle from current UTC date
    final utcToday = DateTime.now().toUtc();
    _targetWord = _dict.getDailySolution(utcToday);

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
      await _storage.recordDailyCompletion();
      await _storage.addCoins(100); // Premium daily reward
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
        margin: const EdgeInsets.only(bottom: 120, left: 60, right: 60),
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

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final dateStr = '${nowUtc.day}/${nowUtc.month}/${nowUtc.year} (UTC)';

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
                  _buildHeader(dateStr),
                  Expanded(
                    child: Center(
                      child: _buildGrid(),
                    ),
                  ),
                  GameKeyboard(
                    keyStates: _keyboardStates,
                    onKeyTapped: _onKeyTapped,
                    onEnterTapped: _onEnterTapped,
                    onDeleteTapped: _onDeleteTapped,
                  ),
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

  Widget _buildHeader(String dateStr) {
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
                dateStr,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.menuWarmAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.streakOrange, size: 20),
              const SizedBox(width: 4),
              Text(
                '${_storage.dailyStreak}d',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.streakOrange,
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
    final gridWidth = (screenWidth * 0.90).clamp(280.0, 380.0);
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
