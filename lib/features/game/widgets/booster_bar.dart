import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class BoosterBar extends StatelessWidget {
  final int userCoins;
  final VoidCallback onHintTapped;
  final VoidCallback onCrosshairTapped;
  final VoidCallback onSkipTapped;

  const BoosterBar({
    super.key,
    required this.userCoins,
    required this.onHintTapped,
    required this.onCrosshairTapped,
    required this.onSkipTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBoosterButton(
            icon: Icons.lightbulb_rounded,
            title: 'HINT',
            accentColor: AppColors.boosterHint,
            onTap: onHintTapped,
          ),
          _buildBoosterButton(
            icon: Icons.gps_fixed_rounded,
            title: 'CROSSHAIR',
            accentColor: AppColors.boosterDart,
            onTap: onCrosshairTapped,
          ),
          _buildBoosterButton(
            icon: Icons.skip_next_rounded,
            title: 'PASS',
            accentColor: AppColors.streakOrange,
            onTap: onSkipTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterButton({
    required IconData icon,
    required String title,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gameHeaderBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLight,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.tileFilled,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.coinGold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 10, color: AppColors.coinGold),
                        Text(
                          'AD',
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
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
        ),
      ),
    );
  }
}
