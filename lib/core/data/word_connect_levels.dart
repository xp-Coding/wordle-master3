/// Word Connect Level Definition
class WordConnectLevelEntry {
  final int levelNumber;
  final List<String> letters;
  final List<String> targetWords;
  final String primaryWord;

  const WordConnectLevelEntry({
    required this.levelNumber,
    required this.letters,
    required this.targetWords,
    required this.primaryWord,
  });
}

/// 50 Progressive Word Connect Radial Anagram Levels
class WordConnectLevels {
  static const List<WordConnectLevelEntry> levels = [
    // -------------------------------------------------------------
    // Levels 1–15: 4-Letter Anagram Wheels
    // -------------------------------------------------------------
    WordConnectLevelEntry(
      levelNumber: 1,
      letters: ['A', 'R', 'T', 'S'],
      targetWords: ['ART', 'RAT', 'TAR', 'STAR', 'RATS', 'ARTS'],
      primaryWord: 'STAR',
    ),
    WordConnectLevelEntry(
      levelNumber: 2,
      letters: ['E', 'A', 'S', 'T'],
      targetWords: ['TEA', 'EAT', 'SEA', 'SET', 'EAST', 'SEAT'],
      primaryWord: 'EAST',
    ),
    WordConnectLevelEntry(
      levelNumber: 3,
      letters: ['P', 'O', 'S', 'T'],
      targetWords: ['TOP', 'POT', 'SPOT', 'STOP', 'POST', 'TOPS'],
      primaryWord: 'POST',
    ),
    WordConnectLevelEntry(
      levelNumber: 4,
      letters: ['L', 'E', 'A', 'P'],
      targetWords: ['ALE', 'APE', 'PAL', 'PEA', 'PALE', 'LEAP', 'PLEA'],
      primaryWord: 'LEAP',
    ),
    WordConnectLevelEntry(
      levelNumber: 5,
      letters: ['C', 'A', 'R', 'E'],
      targetWords: ['ARC', 'ACE', 'EAR', 'ERA', 'CAR', 'RACE', 'CARE'],
      primaryWord: 'CARE',
    ),
    WordConnectLevelEntry(
      levelNumber: 6,
      letters: ['N', 'O', 'T', 'E'],
      targetWords: ['NET', 'NOT', 'ONE', 'TON', 'TOE', 'NOTE', 'TONE'],
      primaryWord: 'NOTE',
    ),
    WordConnectLevelEntry(
      levelNumber: 7,
      letters: ['D', 'E', 'A', 'R'],
      targetWords: ['ARE', 'EAR', 'ERA', 'RED', 'DARE', 'DEAR', 'READ'],
      primaryWord: 'DEAR',
    ),
    WordConnectLevelEntry(
      levelNumber: 8,
      letters: ['F', 'I', 'R', 'E'],
      targetWords: ['FIR', 'REF', 'RIF', 'FIRE', 'RIFE'],
      primaryWord: 'FIRE',
    ),
    WordConnectLevelEntry(
      levelNumber: 9,
      letters: ['S', 'O', 'N', 'G'],
      targetWords: ['SON', 'NOG', 'SOG', 'SONG', 'NOGS'],
      primaryWord: 'SONG',
    ),
    WordConnectLevelEntry(
      levelNumber: 10,
      letters: ['G', 'A', 'M', 'E'],
      targetWords: ['AGE', 'GEM', 'MAG', 'GAME', 'MAGE'],
      primaryWord: 'GAME',
    ),
    WordConnectLevelEntry(
      levelNumber: 11,
      letters: ['L', 'I', 'O', 'N'],
      targetWords: ['OIL', 'ION', 'NIL', 'LION', 'LOIN'],
      primaryWord: 'LION',
    ),
    WordConnectLevelEntry(
      levelNumber: 12,
      letters: ['W', 'I', 'N', 'D'],
      targetWords: ['WIN', 'DIN', 'WIND'],
      primaryWord: 'WIND',
    ),
    WordConnectLevelEntry(
      levelNumber: 13,
      letters: ['R', 'O', 'S', 'E'],
      targetWords: ['ROE', 'ORE', 'SORE', 'ROSE'],
      primaryWord: 'ROSE',
    ),
    WordConnectLevelEntry(
      levelNumber: 14,
      letters: ['C', 'A', 'L', 'M'],
      targetWords: ['CAM', 'MAC', 'CLAM', 'CALM'],
      primaryWord: 'CALM',
    ),
    WordConnectLevelEntry(
      levelNumber: 15,
      letters: ['P', 'A', 'T', 'H'],
      targetWords: ['HAT', 'PAT', 'TAP', 'PATH'],
      primaryWord: 'PATH',
    ),

    // -------------------------------------------------------------
    // Levels 16–35: 5-Letter Radial Wheels
    // -------------------------------------------------------------
    WordConnectLevelEntry(
      levelNumber: 16,
      letters: ['S', 'M', 'I', 'L', 'E'],
      targetWords: ['SLIM', 'LIME', 'MILE', 'SEMI', 'SMILE', 'SLIME'],
      primaryWord: 'SMILE',
    ),
    WordConnectLevelEntry(
      levelNumber: 17,
      letters: ['P', 'L', 'A', 'N', 'T'],
      targetWords: ['PLAN', 'PANT', 'PLAT', 'PLANT'],
      primaryWord: 'PLANT',
    ),
    WordConnectLevelEntry(
      levelNumber: 18,
      letters: ['S', 'P', 'A', 'R', 'K'],
      targetWords: ['PARK', 'SPARK', 'SPAR', 'RAPS', 'RASK'],
      primaryWord: 'SPARK',
    ),
    WordConnectLevelEntry(
      levelNumber: 19,
      letters: ['B', 'R', 'E', 'A', 'D'],
      targetWords: ['BED', 'BAD', 'RED', 'BARE', 'BEAR', 'READ', 'BREAD'],
      primaryWord: 'BREAD',
    ),
    WordConnectLevelEntry(
      levelNumber: 20,
      letters: ['H', 'E', 'A', 'R', 'T'],
      targetWords: ['ART', 'HAT', 'EAR', 'HEAT', 'HATE', 'HEAR', 'HEART'],
      primaryWord: 'HEART',
    ),
    WordConnectLevelEntry(
      levelNumber: 21,
      letters: ['S', 'T', 'O', 'N', 'E'],
      targetWords: ['ONE', 'NOT', 'TON', 'TOE', 'TONE', 'NOTE', 'SENT', 'STONE'],
      primaryWord: 'STONE',
    ),
    WordConnectLevelEntry(
      levelNumber: 22,
      letters: ['C', 'L', 'O', 'U', 'D'],
      targetWords: ['COD', 'OLD', 'COLD', 'LOUD', 'CLOUD'],
      primaryWord: 'CLOUD',
    ),
    WordConnectLevelEntry(
      levelNumber: 23,
      letters: ['W', 'A', 'T', 'E', 'R'],
      targetWords: ['WAR', 'RAW', 'WET', 'RATE', 'TEAR', 'WEAR', 'WATER'],
      primaryWord: 'WATER',
    ),
    WordConnectLevelEntry(
      levelNumber: 24,
      letters: ['S', 'P', 'A', 'C', 'E'],
      targetWords: ['ACE', 'APE', 'CAP', 'PEA', 'CASE', 'PACE', 'SPACE'],
      primaryWord: 'SPACE',
    ),
    WordConnectLevelEntry(
      levelNumber: 25,
      letters: ['M', 'A', 'G', 'I', 'C'],
      targetWords: ['AIM', 'CAM', 'MAC', 'MAGI', 'MAGIC'],
      primaryWord: 'MAGIC',
    ),
    WordConnectLevelEntry(
      levelNumber: 26,
      letters: ['T', 'I', 'G', 'E', 'R'],
      targetWords: ['GET', 'TIRE', 'RITE', 'GRIT', 'TIGER'],
      primaryWord: 'TIGER',
    ),
    WordConnectLevelEntry(
      levelNumber: 27,
      letters: ['S', 'U', 'G', 'A', 'R'],
      targetWords: ['RAG', 'GAS', 'RUG', 'SAG', 'RAGS', 'SUGAR'],
      primaryWord: 'SUGAR',
    ),
    WordConnectLevelEntry(
      levelNumber: 28,
      letters: ['F', 'L', 'A', 'M', 'E'],
      targetWords: ['ALE', 'ELF', 'FAME', 'LEAF', 'MALE', 'MEAL', 'FLAME'],
      primaryWord: 'FLAME',
    ),
    WordConnectLevelEntry(
      levelNumber: 29,
      letters: ['O', 'C', 'E', 'A', 'N'],
      targetWords: ['ACE', 'CAN', 'ONE', 'CONE', 'ONCE', 'ACNE', 'OCEAN'],
      primaryWord: 'OCEAN',
    ),
    WordConnectLevelEntry(
      levelNumber: 30,
      letters: ['D', 'R', 'E', 'A', 'M'],
      targetWords: ['DAM', 'EAR', 'ARM', 'MAD', 'DARE', 'DEAR', 'MADE', 'DREAM'],
      primaryWord: 'DREAM',
    ),
    WordConnectLevelEntry(
      levelNumber: 31,
      letters: ['G', 'R', 'A', 'P', 'E'],
      targetWords: ['APE', 'EAR', 'PAG', 'PAGE', 'PEAR', 'REAP', 'GRAPE'],
      primaryWord: 'GRAPE',
    ),
    WordConnectLevelEntry(
      levelNumber: 32,
      letters: ['L', 'E', 'M', 'O', 'N'],
      targetWords: ['MEN', 'ONE', 'ELM', 'LONE', 'MOLE', 'OMEN', 'LEMON'],
      primaryWord: 'LEMON',
    ),
    WordConnectLevelEntry(
      levelNumber: 33,
      letters: ['B', 'L', 'O', 'O', 'M'],
      targetWords: ['BOO', 'MOB', 'LOOM', 'BOOM', 'BLOOM'],
      primaryWord: 'BLOOM',
    ),
    WordConnectLevelEntry(
      levelNumber: 34,
      letters: ['S', 'H', 'A', 'R', 'K'],
      targetWords: ['ARK', 'ASH', 'HAS', 'HARK', 'RASH', 'SHARK'],
      primaryWord: 'SHARK',
    ),
    WordConnectLevelEntry(
      levelNumber: 35,
      letters: ['C', 'R', 'O', 'W', 'N'],
      targetWords: ['COW', 'NOW', 'WON', 'ROW', 'CORN', 'CROW', 'WORN', 'CROWN'],
      primaryWord: 'CROWN',
    ),

    // -------------------------------------------------------------
    // Levels 36–50: 6-Letter Radial Challenge Wheels
    // -------------------------------------------------------------
    WordConnectLevelEntry(
      levelNumber: 36,
      letters: ['P', 'L', 'A', 'N', 'E', 'T'],
      targetWords: ['LATE', 'LANE', 'PLAN', 'PALE', 'LEAP', 'NEAT', 'PLANT', 'PLATE', 'PANEL', 'PLANET'],
      primaryWord: 'PLANET',
    ),
    WordConnectLevelEntry(
      levelNumber: 37,
      letters: ['S', 'I', 'L', 'V', 'E', 'R'],
      targetWords: ['LIVE', 'EVIL', 'VEIL', 'RILE', 'VILE', 'SLIVE', 'SILVER'],
      primaryWord: 'SILVER',
    ),
    WordConnectLevelEntry(
      levelNumber: 38,
      letters: ['S', 'P', 'R', 'I', 'N', 'G'],
      targetWords: ['PIN', 'PIG', 'RIP', 'SIN', 'RING', 'GRIP', 'PING', 'SPIN', 'SPRING'],
      primaryWord: 'SPRING',
    ),
    WordConnectLevelEntry(
      levelNumber: 39,
      letters: ['W', 'I', 'N', 'T', 'E', 'R'],
      targetWords: ['WET', 'WIN', 'TIE', 'RENT', 'WIRE', 'TIRE', 'TWIN', 'WRITE', 'WINTER'],
      primaryWord: 'WINTER',
    ),
    WordConnectLevelEntry(
      levelNumber: 40,
      letters: ['F', 'O', 'R', 'E', 'S', 'T'],
      targetWords: ['FOR', 'ROE', 'SORE', 'ROTE', 'FORT', 'SOFT', 'REST', 'SORT', 'FOREST'],
      primaryWord: 'FOREST',
    ),
    WordConnectLevelEntry(
      levelNumber: 41,
      letters: ['C', 'A', 'S', 'T', 'L', 'E'],
      targetWords: ['ACT', 'CAT', 'SET', 'TEA', 'LATE', 'EAST', 'SALE', 'TALE', 'SCALE', 'CASTLE'],
      primaryWord: 'CASTLE',
    ),
    WordConnectLevelEntry(
      levelNumber: 42,
      letters: ['K', 'N', 'I', 'G', 'H', 'T'],
      targetWords: ['GIN', 'HIT', 'TIN', 'HINT', 'THIN', 'NIGHT', 'KNIGHT'],
      primaryWord: 'KNIGHT',
    ),
    WordConnectLevelEntry(
      levelNumber: 43,
      letters: ['I', 'S', 'L', 'A', 'N', 'D'],
      targetWords: ['AND', 'LID', 'SAD', 'SIN', 'LAND', 'SAIL', 'DIAL', 'LAID', 'ISLAND'],
      primaryWord: 'ISLAND',
    ),
    WordConnectLevelEntry(
      levelNumber: 44,
      letters: ['F', 'L', 'O', 'W', 'E', 'R'],
      targetWords: ['FOR', 'LOW', 'ROW', 'FLOW', 'WOLF', 'FORE', 'LORE', 'ROLE', 'FLOWER'],
      primaryWord: 'FLOWER',
    ),
    WordConnectLevelEntry(
      levelNumber: 45,
      letters: ['T', 'O', 'W', 'E', 'R', 'S'],
      targetWords: ['TOE', 'TWO', 'ROW', 'WET', 'REST', 'ROSE', 'SORE', 'TORE', 'TOWER', 'TOWERS'],
      primaryWord: 'TOWERS',
    ),
    WordConnectLevelEntry(
      levelNumber: 46,
      letters: ['G', 'A', 'R', 'D', 'E', 'N'],
      targetWords: ['AGE', 'DEN', 'EAR', 'END', 'RED', 'DEAR', 'DARE', 'GEAR', 'NEAR', 'GARDEN'],
      primaryWord: 'GARDEN',
    ),
    WordConnectLevelEntry(
      levelNumber: 47,
      letters: ['M', 'O', 'N', 'K', 'E', 'Y'],
      targetWords: ['KEY', 'MEN', 'ONE', 'MONK', 'OMEN', 'YOKE', 'MONEY', 'MONKEY'],
      primaryWord: 'MONKEY',
    ),
    WordConnectLevelEntry(
      levelNumber: 48,
      letters: ['W', 'I', 'Z', 'A', 'R', 'D'],
      targetWords: ['RAW', 'WAR', 'RID', 'DRAW', 'RAID', 'WARD', 'WIZARD'],
      primaryWord: 'WIZARD',
    ),
    WordConnectLevelEntry(
      levelNumber: 49,
      letters: ['O', 'R', 'A', 'N', 'G', 'E'],
      targetWords: ['AGE', 'EAR', 'ONE', 'RAG', 'GEAR', 'NEAR', 'GONE', 'ROAN', 'GROAN', 'ORANGE'],
      primaryWord: 'ORANGE',
    ),
    WordConnectLevelEntry(
      levelNumber: 50,
      letters: ['G', 'A', 'L', 'A', 'X', 'Y'],
      targetWords: ['GAY', 'LAY', 'LAX', 'GALA', 'GALAXY'],
      primaryWord: 'GALAXY',
    ),
  ];

  static WordConnectLevelEntry getLevel(int levelNumber) {
    final clamped = levelNumber.clamp(1, levels.length);
    return levels[clamped - 1];
  }
}
