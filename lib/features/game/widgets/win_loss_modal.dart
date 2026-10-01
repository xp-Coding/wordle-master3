import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class WinLossModal extends StatelessWidget {
  final bool isWin;
  final String solution;
  final int coinsEarned;
  final int currentStreak;
  final int attemptsUsed;
  final VoidCallback onNextWord;
  final VoidCallback onMainMenu;

  const WinLossModal({
    super.key,
    required this.isWin,
    required this.solution,
    required this.coinsEarned,
    required this.currentStreak,
    required this.attemptsUsed,
    required this.onNextWord,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.gameHeaderBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isWin
                ? AppColors.tileCorrect.withValues(alpha: 0.6)
                : Colors.redAccent.withValues(alpha: 0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isWin ? AppColors.tileCorrect : Colors.redAccent)
                  .withValues(alpha: 0.25),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isWin
                      ? [AppColors.tileCorrect, AppColors.tileCorrectBevel]
                      : [Colors.redAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isWin ? AppColors.tileCorrect : Colors.redAccent)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isWin ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isWin ? 'MAGNIFICENT!' : 'NICE TRY!',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isWin ? Colors.greenAccent : Colors.redAccent,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle / Solution display
            Text(
              'The word was',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tileFilled,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.tileFilledBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                solution.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gameBgGradientStart.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    label: 'REWARD',
                    value: '+$coinsEarned',
                    icon: Icons.monetization_on,
                    iconColor: AppColors.coinGold,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.tileEmptyBorder,
                  ),
                  _buildStatItem(
                    label: 'STREAK',
                    value: '$currentStreak',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.streakOrange,
                  ),
                  if (isWin) ...[
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.tileEmptyBorder,
                    ),
                    _buildStatItem(
                      label: 'TRIES',
                      value: '$attemptsUsed / 6',
                      icon: Icons.speed_rounded,
                      iconColor: AppColors.boosterHint,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMainMenu,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.tileFilledBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'MENU',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onNextWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isWin ? AppColors.tileCorrect : AppColors.menuWarmAmber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isWin ? 'NEXT WORD' : 'TRY AGAIN',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
