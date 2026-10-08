/// Classic Wordle Mode Level Definition
class ClassicLevel {
  final int levelNumber;
  final String targetWord;
  final List<String> emojiClues;

  const ClassicLevel({
    required this.levelNumber,
    required this.targetWord,
    required this.emojiClues,
  });

  int get wordLength => targetWord.length;
}

/// 50 Progressive Classic Wordle Levels
/// Scaling:
/// Levels 1–15: 4-letter words
/// Levels 16–40: 5-letter words
/// Levels 41–50: 6-letter words
class ClassicLevels {
  static const List<ClassicLevel> levels = [
    // -------------------------------------------------------------
    // Levels 1–15: 4-Letter Foundation Puzzles (Associative Clues)
    // -------------------------------------------------------------
    ClassicLevel(
      levelNumber: 1,
      targetWord: 'BIRD',
      emojiClues: ['🪶', '🪺', '🌳', '🌤️'],
    ),
    ClassicLevel(
      levelNumber: 2,
      targetWord: 'FISH',
      emojiClues: ['🌊', '🪝', '🫧', '🪸'],
    ),
    ClassicLevel(
      levelNumber: 3,
      targetWord: 'MOON',
      emojiClues: ['⭐', '🌌', '🐺', '🔭'],
    ),
    ClassicLevel(
      levelNumber: 4,
      targetWord: 'FIRE',
      emojiClues: ['🪵', '⛺', '🌡️', '🚒'],
    ),
    ClassicLevel(
      levelNumber: 5,
      targetWord: 'ROSE',
      emojiClues: ['💐', '🌿', '❤️', '🪴'],
    ),
    ClassicLevel(
      levelNumber: 6,
      targetWord: 'STAR',
      emojiClues: ['🌌', '✨', '🔭', '🌃'],
    ),
    ClassicLevel(
      levelNumber: 7,
      targetWord: 'LION',
      emojiClues: ['👑', '🥩', '🐾', '🌍'],
    ),
    ClassicLevel(
      levelNumber: 8,
      targetWord: 'SNOW',
      emojiClues: ['🧣', '🎿', '🧤', '🏔️'],
    ),
    ClassicLevel(
      levelNumber: 9,
      targetWord: 'RAIN',
      emojiClues: ['☂️', '👢', '🌱', '🌈'],
    ),
    ClassicLevel(
      levelNumber: 10,
      targetWord: 'BOOK',
      emojiClues: ['👓', '✍️', '🏫', '🔖'],
    ),
    ClassicLevel(
      levelNumber: 11,
      targetWord: 'SHIP',
      emojiClues: ['⚓', '🌊', '🧭', '🏴‍☠️'],
    ),
    ClassicLevel(
      levelNumber: 12,
      targetWord: 'CAKE',
      emojiClues: ['🕯️', '🎉', '🧁', '🎈'],
    ),
    ClassicLevel(
      levelNumber: 13,
      targetWord: 'FROG',
      emojiClues: ['🪷', '💧', '🪰', '🦘'],
    ),
    ClassicLevel(
      levelNumber: 14,
      targetWord: 'GOLD',
      emojiClues: ['⛏️', '💍', '🏆', '🏦'],
    ),
    ClassicLevel(
      levelNumber: 15,
      targetWord: 'WIND',
      emojiClues: ['🪁', '🍃', '⛵', '🌬️'],
    ),

    // -------------------------------------------------------------
    // Levels 16–40: 5-Letter Core Wordle Puzzles (Associative Clues)
    // -------------------------------------------------------------
    ClassicLevel(
      levelNumber: 16,
      targetWord: 'APPLE',
      emojiClues: ['🥧', '🩺', '🌳', '🍂'],
    ),
    ClassicLevel(
      levelNumber: 17,
      targetWord: 'BREAD',
      emojiClues: ['🌾', '🥪', '🧈', '👨‍🍳'],
    ),
    ClassicLevel(
      levelNumber: 18,
      targetWord: 'CHESS',
      emojiClues: ['🧠', '⏱️', '⬛', '🏆'],
    ),
    ClassicLevel(
      levelNumber: 19,
      targetWord: 'CROWN',
      emojiClues: ['🤴', '💎', '🏰', '👸'],
    ),
    ClassicLevel(
      levelNumber: 20,
      targetWord: 'DREAM',
      emojiClues: ['💭', '💤', '🌙', '✨'],
    ),
    ClassicLevel(
      levelNumber: 21,
      targetWord: 'EAGLE',
      emojiClues: ['🏔️', '🪶', '🇺🇸', '🔭'],
    ),
    ClassicLevel(
      levelNumber: 22,
      targetWord: 'FLAME',
      emojiClues: ['🪵', '🕯️', '🚒', '✨'],
    ),
    ClassicLevel(
      levelNumber: 23,
      targetWord: 'GHOST',
      emojiClues: ['🏚️', '🎃', '🕯️', '😱'],
    ),
    ClassicLevel(
      levelNumber: 24,
      targetWord: 'HEART',
      emojiClues: ['🩺', '💓', '💘', '🏥'],
    ),
    ClassicLevel(
      levelNumber: 25,
      targetWord: 'HORSE',
      emojiClues: ['🤠', '🌾', '🚜', '🏇'],
    ),
    ClassicLevel(
      levelNumber: 26,
      targetWord: 'JUICE',
      emojiClues: ['🍊', '🍹', '🥤', '🧊'],
    ),
    ClassicLevel(
      levelNumber: 27,
      targetWord: 'KNIFE',
      emojiClues: ['🥩', '🍽️', '👨‍🍳', '🧅'],
    ),
    ClassicLevel(
      levelNumber: 28,
      targetWord: 'LEMON',
      emojiClues: ['🍹', '🟡', '🥧', '🧂'],
    ),
    ClassicLevel(
      levelNumber: 29,
      targetWord: 'MAGIC',
      emojiClues: ['✨', '🎩', '🐰', '🔮'],
    ),
    ClassicLevel(
      levelNumber: 30,
      targetWord: 'MUSIC',
      emojiClues: ['🎸', '🎧', '📻', '🎙️'],
    ),
    ClassicLevel(
      levelNumber: 31,
      targetWord: 'NIGHT',
      emojiClues: ['⭐', '🦉', '🛌', '🌌'],
    ),
    ClassicLevel(
      levelNumber: 32,
      targetWord: 'OCEAN',
      emojiClues: ['🏖️', '⛵', '🐋', '🪸'],
    ),
    ClassicLevel(
      levelNumber: 33,
      targetWord: 'PEARL',
      emojiClues: ['🦪', '💍', '✨', '🌊'],
    ),
    ClassicLevel(
      levelNumber: 34,
      targetWord: 'PIZZA',
      emojiClues: ['🧀', '🍅', '🇮🇹', '📦'],
    ),
    ClassicLevel(
      levelNumber: 35,
      targetWord: 'QUEEN',
      emojiClues: ['🏰', '💎', '♟️', '🇬🇧'],
    ),
    ClassicLevel(
      levelNumber: 36,
      targetWord: 'ROBOT',
      emojiClues: ['⚙️', '🔋', '💻', '🦾'],
    ),
    ClassicLevel(
      levelNumber: 37,
      targetWord: 'SHARK',
      emojiClues: ['🦷', '🏊', '🤿', '🌊'],
    ),
    ClassicLevel(
      levelNumber: 38,
      targetWord: 'SPACE',
      emojiClues: ['🚀', '🪐', '🌌', '👽'],
    ),
    ClassicLevel(
      levelNumber: 39,
      targetWord: 'TIGER',
      emojiClues: ['🌿', '🐾', '🥩', '🟠'],
    ),
    ClassicLevel(
      levelNumber: 40,
      targetWord: 'WATER',
      emojiClues: ['🚰', '🧊', '🏜️', '🚿'],
    ),

    // -------------------------------------------------------------
    // Levels 41–50: 6-Letter Challenge Words (Associative Clues)
    // -------------------------------------------------------------
    ClassicLevel(
      levelNumber: 41,
      targetWord: 'CASTLE',
      emojiClues: ['🛡️', '👑', '⚔️', '🐎'],
    ),
    ClassicLevel(
      levelNumber: 42,
      targetWord: 'DRAGON',
      emojiClues: ['🔥', '🏰', '🗡️', '🦇'],
    ),
    ClassicLevel(
      levelNumber: 43,
      targetWord: 'FOREST',
      emojiClues: ['🍄', '🏕️', '🦌', '🪵'],
    ),
    ClassicLevel(
      levelNumber: 44,
      targetWord: 'GALAXY',
      emojiClues: ['🪐', '✨', '🚀', '🔭'],
    ),
    ClassicLevel(
      levelNumber: 45,
      targetWord: 'ISLAND',
      emojiClues: ['🌴', '🥥', '🌊', '⛵'],
    ),
    ClassicLevel(
      levelNumber: 46,
      targetWord: 'KNIGHT',
      emojiClues: ['🤺', '🛡️', '⚔️', '🐎'],
    ),
    ClassicLevel(
      levelNumber: 47,
      targetWord: 'MONKEY',
      emojiClues: ['🍌', '🌴', '🧗', '🥜'],
    ),
    ClassicLevel(
      levelNumber: 48,
      targetWord: 'ORANGE',
      emojiClues: ['🍹', '🎨', '🌳', '🌞'],
    ),
    ClassicLevel(
      levelNumber: 49,
      targetWord: 'PLANET',
      emojiClues: ['🔭', '🌌', '🚀', '☀️'],
    ),
    ClassicLevel(
      levelNumber: 50,
      targetWord: 'WIZARD',
      emojiClues: ['🪄', '🔮', '✨', '📜'],
    ),
  ];

  static ClassicLevel getLevel(int levelNumber) {
    final clamped = levelNumber.clamp(1, levels.length);
    return levels[clamped - 1];
  }
}
