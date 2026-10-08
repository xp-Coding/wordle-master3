import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/three_clues_levels.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_storage.dart';
import '../../../core/theme/app_colors.dart';

class ThreeCluesScreen extends StatefulWidget {
  final int? initialLevel;

  const ThreeCluesScreen({
    super.key,
    this.initialLevel,
  });

  @override
  State<ThreeCluesScreen> createState() => _ThreeCluesScreenState();
}

class _ThreeCluesScreenState extends State<ThreeCluesScreen> {
  final AudioService _audio = AudioService();
  final GameStorage _storage = GameStorage();
  final AdService _adService = AdService();

  late int _currentLevelNumber;
  late ThreeCluesPuzzle _puzzle;
  late List<String> _bankLetters;

  // Selected letters for solution slots
  final List<String?> _selectedSlots = [];
  // Bank state: track which bank indices are tapped
  final Set<int> _usedBankIndices = {};

  int _strikes = 0;
  static const int _maxStrikes = 3;
  bool _isGameOver = false;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.initialLevel ?? _storage.threeCluesLevel;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadPuzzle(_currentLevelNumber);
  }

  void _loadPuzzle(int levelNum) {
    setState(() {
      _currentLevelNumber = levelNum.clamp(1, 50);
      _puzzle = ThreeCluesLevels.getPuzzle(_currentLevelNumber);
      _bankLetters = _puzzle.generateBankLetters(totalBankSize: 12);
      _selectedSlots.clear();
      _selectedSlots.addAll(List.generate(_puzzle.solution.length, (_) => null));
      _usedBankIndices.clear();
      _strikes = 0;
      _isGameOver = false;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onBankLetterTapped(int index, String letter) {
    if (_isGameOver || _usedBankIndices.contains(index)) return;

    final firstEmptySlot = _selectedSlots.indexOf(null);
    if (firstEmptySlot == -1) return;

    _audio.playSfx(GameSfx.click);
    setState(() {
      _selectedSlots[firstEmptySlot] = letter;
      _usedBankIndices.add(index);
    });

    if (!_selectedSlots.contains(null)) {
      _checkSolution();
    }
  }

  void _onSlotTapped(int slotIndex) {
    if (_isGameOver) return;
    final letter = _selectedSlots[slotIndex];
    if (letter == null) return;

    _audio.playSfx(GameSfx.click);
    int? restoreBankIdx;
    for (final idx in _usedBankIndices) {
      if (_bankLetters[idx] == letter) {
        restoreBankIdx = idx;
        break;
      }
    }

    setState(() {
      _selectedSlots[slotIndex] = null;
      if (restoreBankIdx != null) {
        _usedBankIndices.remove(restoreBankIdx);
      }
    });
  }

  void _checkSolution() {
    final guessedWord = _selectedSlots.join();
    if (guessedWord == _puzzle.solution) {
      _handleWin();
    } else {
      _handleStrike();
    }
  }

  Future<void> _handleWin() async {
    _audio.playSfx(GameSfx.win);
    _confettiController.play();
    await _storage.addCoins(40);
    await _storage.addXp(30);
    await _storage.advanceThreeCluesLevel();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.gameHeaderBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.tileCorrect, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.tileCorrect.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.coinGold, size: 56),
              const SizedBox(height: 12),
              Text(
                'PUZZLE SOLVED!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Solution: ${_puzzle.solution}',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+40 Coins & +30 XP',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.coinGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _loadPuzzle(_currentLevelNumber + 1);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.tileCorrect),
                child: const Text('NEXT PUZZLE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStrike() {
    _audio.playSfx(GameSfx.strike);
    setState(() {
      _strikes++;
      _selectedSlots.fillRange(0, _selectedSlots.length, null);
      _usedBankIndices.clear();
    });

    if (_strikes >= _maxStrikes) {
      setState(() {
        _isGameOver = true;
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gameHeaderBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'OUT OF LIVES!',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The answer was: ${_puzzle.solution}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _loadPuzzle(_currentLevelNumber);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.menuWarmAmber),
                    child: const Text('TRY AGAIN'),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  // ==========================================
  // HINT & PASS ACTIONS
  // ==========================================
  Future<void> _useHint() async {
    if (_isGameOver) return;

    // Find the first unfilled slot
    int emptySlot = -1;
    for (int i = 0; i < _puzzle.solution.length; i++) {
      if (_selectedSlots[i] != _puzzle.solution[i]) {
        emptySlot = i;
        break;
      }
    }
    if (emptySlot == -1) return;

    if (_storage.coins < 30) {
      final watched = await _adService.showRewardedAd(
        context: context,
        placement: 'Free Hint in 3 Clues',
        onRewardGranted: () {},
      );
      if (!watched) return;
    } else {
      final deducted = await _storage.deductCoins(30);
      if (!deducted) return;
    }

    _audio.playSfx(GameSfx.booster);
    final targetChar = _puzzle.solution[emptySlot];

    // Find an unused bank index with this targetChar
    int? bankIdx;
    for (int i = 0; i < _bankLetters.length; i++) {
      if (_bankLetters[i] == targetChar && !_usedBankIndices.contains(i)) {
        bankIdx = i;
        break;
      }
    }

    setState(() {
      _selectedSlots[emptySlot] = targetChar;
      if (bankIdx != null) {
        _usedBankIndices.add(bankIdx);
      }
    });

    if (!_selectedSlots.contains(null)) {
      _checkSolution();
    }
  }

  void _usePass() {
    if (_isGameOver) return;
    _audio.playSfx(GameSfx.booster);
    _loadPuzzle(_currentLevelNumber + 1);
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
                  const SizedBox(height: 8),
                  _buildClueCards(),
                  const Spacer(),
                  _buildSolutionSlots(),
                  const SizedBox(height: 16),
                  _buildActionBar(),
                  const SizedBox(height: 12),
                  _buildLetterBank(),
                  const SizedBox(height: 12),
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
                'LEVEL $_currentLevelNumber / 50',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(_maxStrikes, (index) {
                  final isLost = index < _strikes;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      isLost ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                      color: isLost ? AppColors.tileAbsent : AppColors.heartRed,
                      size: 18,
                    ),
                  );
                }),
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

  Widget _buildClueCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '3 CLUES • 1 SOLUTION',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _puzzle.clues.map((clue) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tileFilled,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.menuWarmAmber.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    clue,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionSlots() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_puzzle.solution.length, (i) {
          final letter = _selectedSlots[i];
          final isFilled = letter != null;

          return GestureDetector(
            onTap: () => _onSlotTapped(i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.tileCorrect : AppColors.tileEmpty,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFilled ? AppColors.tileCorrectBevel : AppColors.tileEmptyBorder,
                  width: 2,
                ),
                boxShadow: [
                  if (isFilled)
                    const BoxShadow(
                      color: AppColors.tileCorrectGlow,
                      blurRadius: 8,
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                letter ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Action bar with HINT and PASS
  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _useHint,
            icon: const Icon(Icons.search_rounded, size: 16),
            label: Text(
              _storage.coins >= 30 ? 'HINT (-30)' : 'HINT (AD)',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.boosterHint,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: _usePass,
            icon: const Icon(Icons.skip_next_rounded, size: 16, color: Colors.white70),
            label: Text(
              'PASS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              side: const BorderSide(color: AppColors.tileFilledBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  /// Randomized letter bank with full shuffling
  Widget _buildLetterBank() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_bankLetters.length, (i) {
          final letter = _bankLetters[i];
          final isUsed = _usedBankIndices.contains(i);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUsed ? null : () => _onBankLetterTapped(i, letter),
              borderRadius: BorderRadius.circular(10),
              child: Opacity(
                opacity: isUsed ? 0.25 : 1.0,
                child: Container(
                  width: 44,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.tileFilled,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.tileFilledBorder,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (!isUsed)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: GoogleFonts.outfit(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
