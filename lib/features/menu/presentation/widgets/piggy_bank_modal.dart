import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';

class PiggyBankModal extends StatefulWidget {
  final VoidCallback onClaimed;

  const PiggyBankModal({
    super.key,
    required this.onClaimed,
  });

  @override
  State<PiggyBankModal> createState() => _PiggyBankModalState();
}

class _PiggyBankModalState extends State<PiggyBankModal> {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  void _claimPiggyCoins() async {
    final coins = await _storage.claimPiggyBank();
    if (coins > 0) {
      _audio.playSfx(GameSfx.coin);
      widget.onClaimed();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Collected +$coins Coins from Piggy Bank!'),
          backgroundColor: AppColors.tileCorrect,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPiggy = _storage.piggyBankCoins;
    const maxCapacity = StorageService.piggyBankCapacity;
    final progress = (currentPiggy / maxCapacity).clamp(0.0, 1.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.gameHeaderBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.pinkAccent.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Piggy Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.savings_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'PIGGY BANK',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Wordle wins fill your piggy bank with extra bonus coins!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),

            // Stored Coins Count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.coinGold, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$currentPiggy / $maxCapacity',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coinGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.tileFilled,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 24),

            // Claim Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: currentPiggy > 0 ? _claimPiggyCoins : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  currentPiggy > 0 ? 'BREAK & CLAIM COINS' : 'EMPTY (PLAY TO FILL)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
