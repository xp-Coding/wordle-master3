import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/dictionary_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

class AssociationScreen extends StatefulWidget {
  final int puzzleIndex;

  const AssociationScreen({
    super.key,
    this.puzzleIndex = 0,
  });

  @override
  State<AssociationScreen> createState() => _AssociationScreenState();
}

class _AssociationScreenState extends State<AssociationScreen> {
  final AudioService _audio = AudioService();
  final DictionaryService _dict = DictionaryService();
  final StorageService _storage = StorageService();

  late int _currentIndex;
  late AssociationPuzzle _puzzle;

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
    _currentIndex = widget.puzzleIndex;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadPuzzle();
  }

  void _loadPuzzle() {
    setState(() {
      _puzzle = _dict.getAssociationPuzzle(_currentIndex);
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
    if (firstEmptySlot == -1) return; // All slots full

    _audio.playSfx(GameSfx.click);
    setState(() {
      _selectedSlots[firstEmptySlot] = letter;
      _usedBankIndices.add(index);
    });

    // Check if slots are now full
    if (!_selectedSlots.contains(null)) {
      _checkSolution();
    }
  }

  void _onSlotTapped(int slotIndex) {
    if (_isGameOver) return;
    final letter = _selectedSlots[slotIndex];
    if (letter == null) return;

    _audio.playSfx(GameSfx.click);
    // Find matching used bank index to restore
    int? restoreBankIdx;
    for (final idx in _usedBankIndices) {
      if (_puzzle.bankLetters[idx] == letter) {
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
      // Victory
      _audio.playSfx(GameSfx.win);
      _confettiController.play();
      _storage.addCoins(40);
      _storage.addXp(30);

      Future.delayed(const Duration(milliseconds: 1000), () {
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppColors.coinGold, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'ASSOCIATION SOLVED!',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.greenAccent,
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
                      setState(() {
                        _currentIndex++;
                        _loadPuzzle();
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.tileCorrect),
                    child: const Text('NEXT PUZZLE'),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      // Strike
      _audio.playSfx(GameSfx.strike);
      setState(() {
        _strikes++;
        // Clear slots and return letters to bank
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
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _loadPuzzle();
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
                  const SizedBox(height: 12),
                  _buildClueCards(),
                  const Spacer(),
                  _buildSolutionSlots(),
                  const SizedBox(height: 24),
                  _buildLetterBank(),
                  const SizedBox(height: 20),
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
          // 3-Strike Life Counter
          Row(
            children: List.generate(_maxStrikes, (index) {
              final isLost = index < _strikes;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  isLost ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                  color: isLost ? AppColors.tileAbsent : AppColors.heartRed,
                  size: 24,
                ),
              );
            }),
          ),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 18),
              const SizedBox(width: 4),
              Text(
                '${_storage.coins}',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coinGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClueCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            '3 CLUES • 1 SOLUTION',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _puzzle.clues.map((clue) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.tileFilled,
                    borderRadius: BorderRadius.circular(16),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_puzzle.solution.length, (i) {
        final letter = _selectedSlots[i];
        final isFilled = letter != null;

        return GestureDetector(
          onTap: () => _onSlotTapped(i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 48,
            height: 52,
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
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterBank() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(_puzzle.bankLetters.length, (i) {
          final letter = _puzzle.bankLetters[i];
          final isUsed = _usedBankIndices.contains(i);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUsed ? null : () => _onBankLetterTapped(i, letter),
              borderRadius: BorderRadius.circular(10),
              child: Opacity(
                opacity: isUsed ? 0.25 : 1.0,
                child: Container(
                  width: 46,
                  height: 48,
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
                      fontSize: 20,
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
