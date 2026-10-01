import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/neon_colors.dart';
import '../../../../core/audio/audio_service.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool soundEnabled = AudioService().isSoundEnabled;
  bool musicEnabled = AudioService().isMusicEnabled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NeonColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeonColors.cyan, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: GoogleFonts.orbitron(
                color: NeonColors.cyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              activeColor: NeonColors.cyan,
              title: Text('SOUND EFFECTS', style: GoogleFonts.orbitron(color: NeonColors.textBright, fontSize: 12)),
              value: soundEnabled,
              onChanged: (val) {
                setState(() => soundEnabled = val);
                AudioService().toggleSound(val);
              },
            ),
            SwitchListTile(
              activeColor: NeonColors.cyan,
              title: Text('SYNTHWAVE MUSIC', style: GoogleFonts.orbitron(color: NeonColors.textBright, fontSize: 12)),
              value: musicEnabled,
              onChanged: (val) {
                setState(() => musicEnabled = val);
                AudioService().toggleMusic(val);
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CLOSE', style: GoogleFonts.orbitron(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
