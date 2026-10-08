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
            icon: Icons.lightbulb_outline,
            title: 'Hint',
            accentColor: AppColors.boosterHint,
            onTap: onHintTapped,
          ),
          _buildBoosterButton(
            icon: Icons.track_changes,
            title: 'Dart',
            accentColor: AppColors.boosterDart,
            onTap: onCrosshairTapped,
          ),
          _buildBoosterButton(
            icon: Icons.skip_next,
            title: 'Pass',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
