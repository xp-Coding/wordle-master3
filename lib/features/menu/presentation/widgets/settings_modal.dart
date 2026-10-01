import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsModal extends StatefulWidget {
  final VoidCallback onChanged;

  const SettingsModal({
    super.key,
    required this.onChanged,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();

  late bool _soundEnabled;
  late int _selectedWordLength;

  @override
  void initState() {
    super.initState();
    _soundEnabled = _storage.isSoundEnabled;
    _selectedWordLength = _storage.wordLength;
  }

  @override
  Widget build(BuildContext context) {
    final winRate = _storage.gamesPlayed > 0
        ? ((_storage.gamesWon / _storage.gamesPlayed) * 100).toStringAsFixed(0)
        : '0';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.gameHeaderBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.tileFilledBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SETTINGS & STATS',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statistics Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gameBgGradientStart,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tileEmptyBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('${_storage.gamesPlayed}', 'PLAYED'),
                  _buildStatColumn('$winRate%', 'WIN %'),
                  _buildStatColumn('${_storage.currentStreak}', 'STREAK'),
                  _buildStatColumn('${_storage.maxStreak}', 'MAX'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sound Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: _soundEnabled ? AppColors.coinGold : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sound Effects',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _soundEnabled,
                  activeTrackColor: AppColors.tileCorrect,
                  activeThumbColor: Colors.white,
                  onChanged: (val) async {
                    setState(() {
                      _soundEnabled = val;
                    });
                    _audio.setSoundEnabled(val);
                    await _storage.setSoundEnabled(val);
                    widget.onChanged();
                  },
                ),
              ],
            ),
            const Divider(color: AppColors.tileFilledBorder, height: 24),

            // Default Word Length Selector (4, 5, 6)
            Text(
              'Classic Grid Word Length',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [4, 5, 6].map((length) {
                final isSelected = _selectedWordLength == length;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _selectedWordLength = length;
                        });
                        await _storage.setWordLength(length);
                        widget.onChanged();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.tileCorrect
                            : AppColors.tileFilled,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.tileCorrectBevel
                                : AppColors.tileFilledBorder,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '$length Letters',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String val, String title) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
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
