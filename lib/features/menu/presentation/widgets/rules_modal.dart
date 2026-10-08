import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Modal dialog displaying comprehensive game rules and gameplay guides.
class RulesModal extends StatefulWidget {
  const RulesModal({super.key});

  @override
  State<RulesModal> createState() => _RulesModalState();
}

class _RulesModalState extends State<RulesModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Classic',
    'Daily',
    'Word Connect',
    '3 Clues',
    'Skills',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 580),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF13192B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.menuWarmAmber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with title and close icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.coinGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'HOW TO PLAY & RULES',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tab bar
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.tileCorrect, AppColors.tileCorrectBevel],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildClassicRules(),
                  _buildDailyRules(),
                  _buildWordConnectRules(),
                  _buildThreeCluesRules(),
                  _buildSkillsRules(),
                ],
              ),
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.menuWarmAmber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'GOT IT, LET\'S PLAY!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicRules() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('Classic Wordle Rules'),
        _buildParagraph(
          'Guess the hidden word in 6 tries. Words scale from 4 letters to 5 and 6-letter challenge words across progressive levels.',
        ),
        const SizedBox(height: 10),
        _buildTileExplanation(
          color: AppColors.tileCorrect,
          title: 'GREEN (CORRECT)',
          description: 'The letter is in the word and in the exact correct position.',
        ),
        _buildTileExplanation(
          color: AppColors.tileMisplaced,
          title: 'YELLOW (MISPLACED)',
          description: 'The letter is in the word but in the wrong position.',
        ),
        _buildTileExplanation(
          color: AppColors.tileAbsent,
          title: 'GRAY (ABSENT)',
          description: 'The letter is not in the target word in any spot.',
        ),
        const SizedBox(height: 10),
        _buildSectionHeader('Associative Emoji Clues'),
        _buildParagraph(
          'At the top of each level, 3–4 emoji riddles give you contextual hints about the word theme without spoiling the actual answer!',
        ),
      ],
    );
  }

  Widget _buildDailyRules() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('Daily Puzzle & Calendar'),
        _buildParagraph(
          'A new synchronized word puzzle unlocks every day based on UTC time! Complete daily puzzles to build your streak and fill the calendar grid.',
        ),
        const SizedBox(height: 10),
        _buildSectionHeader('Grand Prize Milestones'),
        _buildTileExplanation(
          color: const Color(0xFFCD7F32),
          title: '🥉 Bronze Chest (3 Wins)',
          description: 'Claim +100 bonus coins after solving 3 daily puzzles this month.',
        ),
        _buildTileExplanation(
          color: const Color(0xFFC0C0C0),
          title: '🥈 Silver Chest (10 Wins)',
          description: 'Claim +250 bonus coins after reaching 10 monthly wins.',
        ),
        _buildTileExplanation(
          color: AppColors.coinGold,
          title: '🥇 Grand Gold Trophy (31 Wins)',
          description: 'Complete the entire calendar to earn the Grand Prize +1,000 Coins!',
        ),
        const SizedBox(height: 10),
        _buildParagraph(
          'Note: If a daily puzzle is skipped using the PASS booster, it will be marked as PASSED on your calendar.',
        ),
      ],
    );
  }

  Widget _buildWordConnectRules() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('Word Connect Rules'),
        _buildParagraph(
          'Swipe your finger across the radial letter circle at the bottom of the screen to connect letters and spell valid words.',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('Find all hidden crossword target words to clear the level.'),
        _buildBulletPoint('Use the SHUFFLE button to rearrange letters on the wheel for fresh perspective.'),
        _buildBulletPoint('Use the REVEAL booster to automatically discover any remaining hidden word!'),
      ],
    );
  }

  Widget _buildThreeCluesRules() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('3 Clues • 1 Word Rules'),
        _buildParagraph(
          'Read the 3 semantic clue cards and deduce the mystery connection word.',
        ),
        const SizedBox(height: 10),
        _buildBulletPoint('Tap letter tiles from the shuffled bank to place them into the slots.'),
        _buildBulletPoint('Slots reflect Wordle colors: Green for exact spot, Yellow for misplaced letter, and Gray if not in the answer!'),
        _buildBulletPoint('You have 3 lives per puzzle. Avoid 3 incorrect submissions or use HINT/PASS to stay in the game!'),
      ],
    );
  }

  Widget _buildSkillsRules() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader('Power-Up Skills & Boosters'),
        _buildParagraph(
          'All game skills can be activated instantly by watching a quick sponsor video clip:',
        ),
        const SizedBox(height: 10),
        _buildTileExplanation(
          color: AppColors.boosterHint,
          title: '💡 HINT SKILL',
          description: 'Reveals an exact letter in its correct position in the active row/slot.',
        ),
        _buildTileExplanation(
          color: Colors.deepPurpleAccent,
          title: '🎯 CROSSHAIR SKILL',
          description: 'Eliminates 3 absent letters from the keyboard, narrowing your options.',
        ),
        _buildTileExplanation(
          color: AppColors.streakOrange,
          title: '⏭️ PASS SKILL',
          description: 'Skips the current level or marks the daily challenge as passed cleanly.',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.coinGold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12.5,
        color: AppColors.textLight,
        height: 1.4,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.coinGold, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                color: AppColors.textLight,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileExplanation({
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
