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
            icon: Icons.search_rounded,
            title: 'HINT',
            cost: 50,
            accentColor: AppColors.boosterHint,
            onTap: onHintTapped,
            canAfford: userCoins >= 50,
          ),
          _buildBoosterButton(
            icon: Icons.gps_fixed_rounded,
            title: 'CROSSHAIR',
            cost: 30,
            accentColor: AppColors.boosterDart,
            onTap: onCrosshairTapped,
            canAfford: userCoins >= 30,
          ),
          _buildBoosterButton(
            icon: Icons.skip_next_rounded,
            title: 'SKIP PASS',
            cost: 0,
            accentColor: AppColors.boosterSkip,
            onTap: onSkipTapped,
            canAfford: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterButton({
    required IconData icon,
    required String title,
    required int cost,
    required Color accentColor,
    required VoidCallback onTap,
    required bool canAfford,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canAfford ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Opacity(
          opacity: canAfford ? 1.0 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gameHeaderBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accentColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                    color: accentColor.withOpacity(0.2),
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
                    Row(
                      children: [
                        if (cost > 0) ...[
                          const Icon(
                            Icons.monetization_on,
                            size: 11,
                            color: AppColors.coinGold,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$cost',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coinGold,
                            ),
                          ),
                        ] else
                          Text(
                            'FREE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
