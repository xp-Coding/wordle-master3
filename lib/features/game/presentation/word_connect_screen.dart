import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/word_connect_levels.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_storage.dart';
import '../../../core/theme/app_colors.dart';

class WordConnectScreen extends StatefulWidget {
  final int? initialLevel;

  const WordConnectScreen({
    super.key,
    this.initialLevel,
  });

  @override
  State<WordConnectScreen> createState() => _WordConnectScreenState();
}

class _WordConnectScreenState extends State<WordConnectScreen> {
  final AudioService _audio = AudioService();
  final GameStorage _storage = GameStorage();
  final AdService _adService = AdService();

  late int _currentLevel;
  late WordConnectLevelEntry _levelData;
  final Set<String> _foundWords = {};

  // Wheel touch drag state
  final List<int> _selectedIndices = [];
  Offset? _currentTouchPoint;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel ?? _storage.wordConnectLevel;
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadLevel(_currentLevel);
  }

  void _loadLevel(int levelNum) {
    setState(() {
      _currentLevel = levelNum.clamp(1, 50);
      _levelData = WordConnectLevels.getLevel(_currentLevel);
      _foundWords.clear();
      _selectedIndices.clear();
      _currentTouchPoint = null;
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String get _currentConstructedWord {
    return _selectedIndices.map((i) => _levelData.letters[i]).join();
  }

  void _onPanStart(Offset localPos, Size wheelSize) {
    _selectedIndices.clear();
    _currentTouchPoint = localPos;
    _checkHit(localPos, wheelSize);
  }

  void _onPanUpdate(Offset localPos, Size wheelSize) {
    setState(() {
      _currentTouchPoint = localPos;
    });
    _checkHit(localPos, wheelSize);
  }

  void _onPanEnd() {
    final word = _currentConstructedWord;
    if (word.isNotEmpty) {
      _evaluateWord(word);
    }
    setState(() {
      _selectedIndices.clear();
      _currentTouchPoint = null;
    });
  }

  void _checkHit(Offset touch, Size wheelSize) {
    final center = Offset(wheelSize.width / 2, wheelSize.height / 2);
    final radius = wheelSize.width * 0.36;
    final numLetters = _levelData.letters.length;
    const nodeRadius = 30.0;

    for (int i = 0; i < numLetters; i++) {
      final angle = (2 * pi / numLetters) * i - (pi / 2);
      final nodeCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      final dist = (touch - nodeCenter).distance;
      if (dist <= nodeRadius) {
        if (!_selectedIndices.contains(i)) {
          _audio.playSfx(GameSfx.click);
          setState(() {
            _selectedIndices.add(i);
          });
        }
      }
    }
  }

  void _evaluateWord(String word) {
    if (_levelData.targetWords.contains(word)) {
      if (_foundWords.contains(word)) {
        _audio.playSfx(GameSfx.error);
        _showToast('Already found!');
      } else {
        _audio.playSfx(GameSfx.coin);
        setState(() {
          _foundWords.add(word);
        });
        _storage.addCoins(10);
        _showToast('Found $word! (+10 Coins)', isPositive: true);

        // Check level win
        if (_foundWords.length >= _levelData.targetWords.length) {
          _handleLevelWin();
        }
      }
    } else {
      _audio.playSfx(GameSfx.error);
    }
  }

  Future<void> _handleLevelWin() async {
    _audio.playSfx(GameSfx.win);
    _confettiController.play();
    await _storage.addCoins(50);
    await _storage.addXp(40);
    await _storage.advanceWordConnectLevel();

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
              const Icon(Icons.stars_rounded, color: AppColors.coinGold, size: 56),
              const SizedBox(height: 12),
              Text(
                'LEVEL $_currentLevel CLEARED!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+50 Bonus Coins & +40 XP',
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
                  _loadLevel(_currentLevel + 1);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.tileCorrect),
                child: const Text('NEXT LEVEL'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String message, {bool isPositive = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isPositive ? AppColors.tileCorrect : Colors.redAccent.shade700,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 240, left: 60, right: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _revealRandomWordHint() async {
    final unfound = _levelData.targetWords.where((w) => !_foundWords.contains(w)).toList();
    if (unfound.isEmpty) return;

    if (_storage.coins < 30) {
      final watched = await _adService.showRewardedAd(
        context: context,
        placement: 'Free Word Connect Hint',
        onRewardGranted: () {},
      );
      if (!watched) return;
    } else {
      final deducted = await _storage.deductCoins(30);
      if (!deducted) return;
    }

    _audio.playSfx(GameSfx.booster);
    final wordToReveal = unfound.first;
    setState(() {
      _foundWords.add(wordToReveal);
    });

    _showToast('Revealed: $wordToReveal!', isPositive: true);

    if (_foundWords.length >= _levelData.targetWords.length) {
      _handleLevelWin();
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
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildTargetWordSlots(),
                          const SizedBox(height: 16),
                          _buildActiveWordPreview(),
                          const SizedBox(height: 16),
                          _buildRadialWheel(),
                          const SizedBox(height: 12),
                          _buildHintButton(),
                        ],
                      ),
                    ),
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
          Text(
            'WORD CONNECT • LVL $_currentLevel / 50',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
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

  Widget _buildTargetWordSlots() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _levelData.targetWords.map((word) {
          final isDiscovered = _foundWords.contains(word);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDiscovered ? AppColors.tileCorrect : AppColors.tileEmpty,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDiscovered ? AppColors.tileCorrectBevel : AppColors.tileEmptyBorder,
                width: 1.5,
              ),
              boxShadow: [
                if (isDiscovered)
                  const BoxShadow(
                    color: AppColors.tileCorrectGlow,
                    blurRadius: 8,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(word.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 16,
                  alignment: Alignment.center,
                  child: Text(
                    isDiscovered ? word[i] : '•',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveWordPreview() {
    final word = _currentConstructedWord;
    return Container(
      height: 44,
      alignment: Alignment.center,
      child: word.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tileFilled,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.menuWarmAmber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.menuWarmAmber.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                word,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildRadialWheel() {
    const wheelSize = Size(240, 240);

    return Center(
      child: GestureDetector(
        onPanStart: (details) => _onPanStart(details.localPosition, wheelSize),
        onPanUpdate: (details) => _onPanUpdate(details.localPosition, wheelSize),
        onPanEnd: (_) => _onPanEnd(),
        child: SizedBox(
          width: wheelSize.width,
          height: wheelSize.height,
          child: CustomPaint(
            painter: _WordConnectWheelPainter(
              letters: _levelData.letters,
              selectedIndices: _selectedIndices,
              currentTouchPoint: _currentTouchPoint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintButton() {
    return ElevatedButton.icon(
      onPressed: _revealRandomWordHint,
      icon: const Icon(Icons.lightbulb_rounded, size: 16),
      label: Text(
        _storage.coins >= 30 ? 'REVEAL WORD (-30 COINS)' : 'REVEAL WORD (WATCH AD)',
        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.boosterHint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _WordConnectWheelPainter extends CustomPainter {
  final List<String> letters;
  final List<int> selectedIndices;
  final Offset? currentTouchPoint;

  _WordConnectWheelPainter({
    required this.letters,
    required this.selectedIndices,
    required this.currentTouchPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;
    const nodeRadius = 24.0;

    // Draw background wheel circle
    final bgPaint = Paint()
      ..color = AppColors.gameHeaderBg.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width / 2, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.tileFilledBorder.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, size.width / 2, borderPaint);

    // Calculate node positions
    final nodePositions = <Offset>[];
    for (int i = 0; i < letters.length; i++) {
      final angle = (2 * pi / letters.length) * i - (pi / 2);
      nodePositions.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }

    // Draw connecting vector lines
    if (selectedIndices.isNotEmpty) {
      final linePaint = Paint()
        ..color = AppColors.menuWarmAmber
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(nodePositions[selectedIndices.first].dx, nodePositions[selectedIndices.first].dy);

      for (int i = 1; i < selectedIndices.length; i++) {
        final pos = nodePositions[selectedIndices[i]];
        path.lineTo(pos.dx, pos.dy);
      }

      if (currentTouchPoint != null) {
        path.lineTo(currentTouchPoint!.dx, currentTouchPoint!.dy);
      }

      canvas.drawPath(path, linePaint);
    }

    // Draw circular letter nodes
    for (int i = 0; i < letters.length; i++) {
      final pos = nodePositions[i];
      final isSelected = selectedIndices.contains(i);

      final nodeBgPaint = Paint()
        ..color = isSelected ? AppColors.menuWarmAmber : AppColors.tileFilled
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, nodeRadius, nodeBgPaint);

      final nodeBorderPaint = Paint()
        ..color = isSelected ? Colors.white : AppColors.tileFilledBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, nodeRadius, nodeBorderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isSelected ? AppColors.textDark : Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WordConnectWheelPainter oldDelegate) => true;
}
