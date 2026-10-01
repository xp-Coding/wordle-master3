import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/board_matrix.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/ads/ad_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../campaign/data/level_definitions.dart';

class WinLossModal extends StatefulWidget {
  final BoardMatrix boardMatrix;
  final VoidCallback onRetry;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;
  final Function(int extraMoves)? onAddExtraMoves;

  const WinLossModal({
    super.key,
    required this.boardMatrix,
    required this.onRetry,
    required this.onNextLevel,
    required this.onMenu,
    this.onAddExtraMoves,
  });

  @override
  State<WinLossModal> createState() => _WinLossModalState();
}

class _WinLossModalState extends State<WinLossModal> {
  bool rewardClaimed = false;

  @override
  Widget build(BuildContext context) {
    bool isWon = widget.boardMatrix.status == GameStatus.won;
    int stars = 0;
    if (isWon && widget.boardMatrix.mode == GameMode.campaign) {
      var level = LevelDefinitions.getLevel(widget.boardMatrix.levelId);
      stars = level.calculateStars(widget.boardMatrix.score, widget.boardMatrix.movesRemaining);
    }

    int baseDataBits = (widget.boardMatrix.score * GameConstants.scoreToBitsRatio).round();
    if (isWon) baseDataBits += (stars * 50);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeonColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWon ? NeonColors.cyan : NeonColors.neonMagenta,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isWon ? NeonColors.cyan : NeonColors.neonMagenta).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWon ? 'SYSTEM PURIFIED' : 'SYSTEM OVERRIDE',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                color: isWon ? NeonColors.cyan : NeonColors.neonMagenta,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: isWon ? NeonColors.cyan : NeonColors.neonMagenta,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Star Rating Display
            if (isWon && widget.boardMatrix.mode == GameMode.campaign)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  bool active = index < stars;
                  return Icon(
                    active ? Icons.star_rounded : Icons.star_border_rounded,
                    color: active ? NeonColors.starGold : NeonColors.textMuted,
                    size: 44,
                  );
                }),
              ),

            const SizedBox(height: 16),
            Text(
              'SCORE: ${widget.boardMatrix.score}',
              style: GoogleFonts.orbitron(
                color: NeonColors.textBright,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+$baseDataBits DATA BITS EARNED',
              style: GoogleFonts.orbitron(
                color: NeonColors.matrixGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // Rewarded Ad Option: Double Rewards or +5 Moves
            if (!rewardClaimed)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: NeonColors.cyberYellow, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  AdService().showRewardedAd(
                    onUserEarnedReward: (reward) {
                      setState(() {
                        rewardClaimed = true;
                      });
                      if (isWon) {
                        int currentBits = StorageService().getDataBits();
                        StorageService().saveDataBits(currentBits + baseDataBits);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Rewards Doubled! +$baseDataBits Extra Data Bits Saved!')),
                        );
                      } else {
                        if (widget.onAddExtraMoves != null) {
                          widget.onAddExtraMoves!(5);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  );
                },
                icon: const Icon(Icons.ondemand_video_rounded, color: NeonColors.cyberYellow),
                label: Text(
                  isWon ? 'WATCH AD: DOUBLE DATA BITS' : 'WATCH AD: +5 EXTRA MOVES',
                  style: GoogleFonts.orbitron(
                    color: NeonColors.cyberYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonColors.cardSurface,
                    side: const BorderSide(color: NeonColors.cyan),
                  ),
                  child: Text('RETRY', style: GoogleFonts.orbitron(color: NeonColors.cyan)),
                ),
                if (isWon && widget.boardMatrix.mode == GameMode.campaign)
                  ElevatedButton(
                    onPressed: widget.onNextLevel,
                    child: Text('NEXT', style: GoogleFonts.orbitron(color: Colors.black)),
                  ),
                ElevatedButton(
                  onPressed: widget.onMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonColors.cardSurface,
                    side: const BorderSide(color: NeonColors.textMuted),
                  ),
                  child: Text('MENU', style: GoogleFonts.orbitron(color: NeonColors.textMuted)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
