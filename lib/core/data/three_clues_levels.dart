import 'dart:math';

/// 3 Clues 1 Word Puzzle Entry
class ThreeCluesPuzzle {
  final int levelNumber;
  final List<String> clues;
  final String solution;

  const ThreeCluesPuzzle({
    required this.levelNumber,
    required this.clues,
    required this.solution,
  });

  /// Generates a randomized letter bank combining the solution characters
  /// with distinct distractor alphabet characters, shuffled thoroughly so
  /// the solution never appears sequentially or at the start.
  List<String> generateBankLetters({int totalBankSize = 12}) {
    final solutionChars = solution.toUpperCase().split('');
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // Distractor candidates not already heavily used
    final distractors = alphabet.split('').where((c) => !solutionChars.contains(c)).toList()
      ..shuffle(Random(levelNumber * 37 + 11));

    final neededDistractors = (totalBankSize - solutionChars.length).clamp(4, 10);
    final bank = <String>[
      ...solutionChars,
      ...distractors.take(neededDistractors),
    ];

    // Shuffle multiple times with seeded pseudo-randomness
    final rand = Random(levelNumber * 101 + solution.hashCode);
    bank.shuffle(rand);
    bank.shuffle(rand);

    // Verify it doesn't accidentally start with the full solution
    if (bank.take(solution.length).join() == solution) {
      bank.shuffle();
    }

    return bank;
  }
}

/// 50 Progressive 3 Clues 1 Word Puzzles
class ThreeCluesLevels {
  static const List<ThreeCluesPuzzle> levels = [
    ThreeCluesPuzzle(
      levelNumber: 1,
      clues: ['BARK', 'TAIL', 'PET'],
      solution: 'DOG',
    ),
    ThreeCluesPuzzle(
      levelNumber: 2,
      clues: ['SKI', 'SNOW', 'COLD'],
      solution: 'ICE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 3,
      clues: ['MEOW', 'PURR', 'WHISKER'],
      solution: 'CAT',
    ),
    ThreeCluesPuzzle(
      levelNumber: 4,
      clues: ['BUZZ', 'HONEY', 'HIVE'],
      solution: 'BEE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 5,
      clues: ['SAND', 'WAVES', 'SUN'],
      solution: 'BEACH',
    ),
    ThreeCluesPuzzle(
      levelNumber: 6,
      clues: ['FLOUR', 'OVEN', 'SLICE'],
      solution: 'BREAD',
    ),
    ThreeCluesPuzzle(
      levelNumber: 7,
      clues: ['PEDAL', 'WHEEL', 'RIDE'],
      solution: 'BIKE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 8,
      clues: ['NIGHT', 'CRATER', 'GLOW'],
      solution: 'MOON',
    ),
    ThreeCluesPuzzle(
      levelNumber: 9,
      clues: ['CROWN', 'CASTLE', 'THRONE'],
      solution: 'KING',
    ),
    ThreeCluesPuzzle(
      levelNumber: 10,
      clues: ['FINS', 'OCEAN', 'GILLS'],
      solution: 'FISH',
    ),
    ThreeCluesPuzzle(
      levelNumber: 11,
      clues: ['FEATHER', 'NEST', 'WINGS'],
      solution: 'BIRD',
    ),
    ThreeCluesPuzzle(
      levelNumber: 12,
      clues: ['CAMP', 'SMOKE', 'FLAME'],
      solution: 'FIRE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 13,
      clues: ['CLOCK', 'WRIST', 'WATCH'],
      solution: 'TIME',
    ),
    ThreeCluesPuzzle(
      levelNumber: 14,
      clues: ['RAIN', 'COLOR', 'SKY'],
      solution: 'RAINBOW',
    ),
    ThreeCluesPuzzle(
      levelNumber: 15,
      clues: ['PAGES', 'COVER', 'READ'],
      solution: 'BOOK',
    ),
    ThreeCluesPuzzle(
      levelNumber: 16,
      clues: ['TREE', 'BARK', 'AUTUMN'],
      solution: 'LEAF',
    ),
    ThreeCluesPuzzle(
      levelNumber: 17,
      clues: ['STORM', 'FLASH', 'BOLT'],
      solution: 'LIGHT',
    ),
    ThreeCluesPuzzle(
      levelNumber: 18,
      clues: ['DOCTOR', 'BED', 'NURSE'],
      solution: 'CLINIC',
    ),
    ThreeCluesPuzzle(
      levelNumber: 19,
      clues: ['KEYS', 'STRINGS', 'MUSIC'],
      solution: 'PIANO',
    ),
    ThreeCluesPuzzle(
      levelNumber: 20,
      clues: ['SWEET', 'COCOA', 'CANDY'],
      solution: 'CHOC',
    ),
    ThreeCluesPuzzle(
      levelNumber: 21,
      clues: ['SAIL', 'ANCHOR', 'MAST'],
      solution: 'SHIP',
    ),
    ThreeCluesPuzzle(
      levelNumber: 22,
      clues: ['SPACE', 'ROCKET', 'ORBIT'],
      solution: 'PLANET',
    ),
    ThreeCluesPuzzle(
      levelNumber: 23,
      clues: ['ROAR', 'MANE', 'JUNGLE'],
      solution: 'LION',
    ),
    ThreeCluesPuzzle(
      levelNumber: 24,
      clues: ['WOOL', 'FARM', 'BLEAT'],
      solution: 'SHEEP',
    ),
    ThreeCluesPuzzle(
      levelNumber: 25,
      clues: ['CHEESE', 'CRUST', 'SLICE'],
      solution: 'PIZZA',
    ),
    ThreeCluesPuzzle(
      levelNumber: 26,
      clues: ['COW', 'WHITE', 'GLASS'],
      solution: 'MILK',
    ),
    ThreeCluesPuzzle(
      levelNumber: 27,
      clues: ['WINTER', 'FROST', 'CARROT'],
      solution: 'SNOWMAN',
    ),
    ThreeCluesPuzzle(
      levelNumber: 28,
      clues: ['DESERT', 'HUMP', 'SAND'],
      solution: 'CAMEL',
    ),
    ThreeCluesPuzzle(
      levelNumber: 29,
      clues: ['MAGIC', 'SPELL', 'WAND'],
      solution: 'WIZARD',
    ),
    ThreeCluesPuzzle(
      levelNumber: 30,
      clues: ['GREEN', 'MOWER', 'YARD'],
      solution: 'GRASS',
    ),
    ThreeCluesPuzzle(
      levelNumber: 31,
      clues: ['PENCIL', 'PAPER', 'WRITE'],
      solution: 'NOTE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 32,
      clues: ['RIVER', 'ARCH', 'CROSS'],
      solution: 'BRIDGE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 33,
      clues: ['TENT', 'SLEEP', 'WOODS'],
      solution: 'CAMP',
    ),
    ThreeCluesPuzzle(
      levelNumber: 34,
      clues: ['STRIPES', 'SAVANNA', 'HORSE'],
      solution: 'ZEBRA',
    ),
    ThreeCluesPuzzle(
      levelNumber: 35,
      clues: ['KERNEL', 'MOVIE', 'BUTTER'],
      solution: 'CORN',
    ),
    ThreeCluesPuzzle(
      levelNumber: 36,
      clues: ['TEETH', 'OCEAN', 'PREDATOR'],
      solution: 'SHARK',
    ),
    ThreeCluesPuzzle(
      levelNumber: 37,
      clues: ['APPLE', 'PIE', 'OVEN'],
      solution: 'BAKE',
    ),
    ThreeCluesPuzzle(
      levelNumber: 38,
      clues: ['ENGINE', 'TRACKS', 'WHISTLE'],
      solution: 'TRAIN',
    ),
    ThreeCluesPuzzle(
      levelNumber: 39,
      clues: ['NIGHT', 'DREAM', 'PILLOW'],
      solution: 'SLEEP',
    ),
    ThreeCluesPuzzle(
      levelNumber: 40,
      clues: ['SHADOW', 'LIGHT', 'SOLAR'],
      solution: 'SUN',
    ),
    ThreeCluesPuzzle(
      levelNumber: 41,
      clues: ['BONE', 'DIG', 'MUSEUM'],
      solution: 'FOSSIL',
    ),
    ThreeCluesPuzzle(
      levelNumber: 42,
      clues: ['CACTUS', 'HEAT', 'DUNES'],
      solution: 'DESERT',
    ),
    ThreeCluesPuzzle(
      levelNumber: 43,
      clues: ['SWORD', 'ARMOR', 'SHIELD'],
      solution: 'KNIGHT',
    ),
    ThreeCluesPuzzle(
      levelNumber: 44,
      clues: ['TOWER', 'BELL', 'HOURLY'],
      solution: 'CLOCK',
    ),
    ThreeCluesPuzzle(
      levelNumber: 45,
      clues: ['ORANGE', 'PEEL', 'SWEET'],
      solution: 'FRUIT',
    ),
    ThreeCluesPuzzle(
      levelNumber: 46,
      clues: ['PIRATE', 'MAP', 'GOLD'],
      solution: 'CHEST',
    ),
    ThreeCluesPuzzle(
      levelNumber: 47,
      clues: ['STAGE', 'ACTOR', 'PLAY'],
      solution: 'DRAMA',
    ),
    ThreeCluesPuzzle(
      levelNumber: 48,
      clues: ['HONEY', 'STING', 'STRIPES'],
      solution: 'WASP',
    ),
    ThreeCluesPuzzle(
      levelNumber: 49,
      clues: ['VOLCANO', 'MAGMA', 'ERUPT'],
      solution: 'LAVA',
    ),
    ThreeCluesPuzzle(
      levelNumber: 50,
      clues: ['GALAXY', 'COSMOS', 'STARS'],
      solution: 'SPACE',
    ),
  ];

  static ThreeCluesPuzzle getPuzzle(int levelNumber) {
    final clamped = levelNumber.clamp(1, levels.length);
    return levels[clamped - 1];
  }
}
