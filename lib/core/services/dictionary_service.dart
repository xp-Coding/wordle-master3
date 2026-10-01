import 'dart:math';

class AssociationPuzzle {
  final List<String> clues;
  final String solution;
  final List<String> bankLetters;

  const AssociationPuzzle({
    required this.clues,
    required this.solution,
    required this.bankLetters,
  });
}

class WordConnectLevel {
  final int level;
  final List<String> wheelLetters;
  final List<String> targetWords;
  final String primaryWord;

  const WordConnectLevel({
    required this.level,
    required this.wheelLetters,
    required this.targetWords,
    required this.primaryWord,
  });
}

class DictionaryService {
  static final DictionaryService _instance = DictionaryService._internal();
  factory DictionaryService() => _instance;
  DictionaryService._internal() {
    _initValidSets();
  }

  // 4-Letter Solution Words
  static const List<String> solutions4 = [
    'COLD', 'FIRE', 'GOLD', 'GAME', 'LIFE', 'MOON', 'STAR', 'BLUE', 'WAVE', 'WIND',
    'TIME', 'BEAR', 'BIRD', 'FISH', 'LION', 'TREE', 'ROSE', 'PARK', 'LAKE', 'SHIP',
    'BOOK', 'SONG', 'HERO', 'LOVE', 'RAIN', 'SNOW', 'GLOW', 'PEAK', 'CALM', 'DAWN',
    'DUST', 'ECHO', 'FROST', 'GATE', 'HAZE', 'ISLE', 'JUMP', 'KITE', 'LUSH', 'MINT',
    'NEST', 'OASIS', 'PALM', 'QUICK', 'RUSH', 'SURF', 'TIDE', 'VALE', 'WISP', 'ZEST'
  ];

  // 5-Letter Solution Words (Wordle Standard)
  static const List<String> solutions5 = [
    'CRANE', 'SLATE', 'PLANT', 'LIGHT', 'HEART', 'DREAM', 'OCEAN', 'RIVER', 'SOLAR', 'FLAME',
    'BRAVE', 'SMART', 'CLOUD', 'WATER', 'STONE', 'PEARL', 'MUSIC', 'STORM', 'SHINE', 'BLOOM',
    'SPACE', 'MAGIC', 'WORLD', 'SWEET', 'PEACE', 'POWER', 'TIGER', 'EAGLE', 'SHARK', 'HORSE',
    'GUIDE', 'QUEST', 'EMBER', 'CHESS', 'BLAZE', 'FROST', 'NIGHT', 'SPARK', 'CROWN', 'ROYAL',
    'HONEY', 'LEMON', 'MANGO', 'BERRY', 'BEACH', 'FOREST', 'CLIFF', 'DESERT', 'HAVEN', 'OASIS',
    'SUGAR', 'BREAD', 'APPLE', 'GRAPE', 'PEACH', 'MELON', 'ROBOT', 'PIXEL', 'RADAR', 'CYBER',
    'NOBLE', 'PRIDE', 'FAITH', 'VALOR', 'GLORY', 'CHARM', 'GRACE', 'HONOR', 'TRUST', 'UNITY',
    'SWIFT', 'VIGOR', 'VIVID', 'BLISS', 'LUCKY', 'HAPPY', 'JOLLY', 'CHEER', 'SMILE', 'LAUGH',
    'TRAIN', 'TRACK', 'DRIVE', 'SPEED', 'MOTOR', 'TURBO', 'DRIFT', 'RACER', 'PILOT', 'FLIGHT',
    'CANDY', 'CRISP', 'FUDGE', 'PIZZA', 'TACOS', 'PASTA', 'STEAK', 'SUSHI', 'SALAD', 'TOAST'
  ];

  // 6-Letter Solution Words
  static const List<String> solutions6 = [
    'PLANET', 'GALAXY', 'SILVER', 'SPRING', 'WINTER', 'SUMMER', 'AUTUMN', 'FOREST', 'STREAM', 'ISLAND',
    'CASTLE', 'PALACE', 'KNIGHT', 'DRAGON', 'WIZARD', 'CRYSTAL', 'SHIELD', 'SWORDS', 'TEMPLE', 'SHRINE',
    'SUNSET', 'SUNRISE', 'SHADOW', 'MIRROR', 'LANTERN', 'BRIDGE', 'TOWER', 'VALLEY', 'CANYON', 'MEADOW',
    'TRAVEL', 'SAFARI', 'VOYAGE', 'ROCKET', 'FLIGHT', 'CRUISE', 'JOURNEY', 'DESTINY', 'CHANCE', 'FORTUNE',
    'JUNGLE', 'NATURE', 'GARDEN', 'FLOWER', 'ORCHID', 'BEACON', 'SPIRIT', 'WONDER', 'LEGEND', 'AURORA'
  ];

  // Additional Accepted Guess Words
  static const List<String> commonWords = [
    'ABOUT', 'ABOVE', 'ABUSE', 'ACTOR', 'ACUTE', 'ADMIT', 'ADOPT', 'ADULT', 'AFTER', 'AGAIN',
    'AGENT', 'AGREE', 'AHEAD', 'ALARM', 'ALBUM', 'ALERT', 'ALIEN', 'ALIGN', 'ALIKE', 'ALIVE',
    'ALLOW', 'ALONE', 'ALONG', 'ALTER', 'AMONG', 'ANGEL', 'ANGER', 'ANGLE', 'ANGRY', 'APART',
    'APPLE', 'APPLY', 'ARENA', 'ARGUE', 'ARISE', 'ARMOR', 'ARRAY', 'ARROW', 'ASIDE', 'ASSET',
    'AUDIO', 'AUDIT', 'AVOID', 'AWAIT', 'AWAKE', 'AWARD', 'AWARE', 'BADGE', 'BASIC', 'BASIN',
    'BASIS', 'BATCH', 'BEACH', 'BEAST', 'BEGIN', 'BEING', 'BELLY', 'BELOW', 'BENCH', 'BLACK',
    'BLADE', 'BLAME', 'BLANK', 'BLAST', 'BLEED', 'BLEND', 'BLIND', 'BLOCK', 'BLOOD', 'BOARD',
    'BOAST', 'BONUS', 'BOOST', 'BOUND', 'BRAIN', 'BRAND', 'BRASS', 'BRAVE', 'BREAD', 'BREAK',
    'BREED', 'BRIEF', 'BRING', 'BROAD', 'BROWN', 'BRUSH', 'BUILD', 'BUNCH', 'BURST', 'CABIN',
    'CABLE', 'CAMEL', 'CANAL', 'CANDY', 'CANOE', 'CARGO', 'CARRY', 'CARVE', 'CATCH', 'CAUSE',
    'CEASE', 'CHAIN', 'CHAIR', 'CHALK', 'CHAMP', 'CHANT', 'CHAOS', 'CHASE', 'CHEAP', 'CHECK',
    'CHEST', 'CHIEF', 'CHILD', 'CHILL', 'CHOIR', 'CHOKE', 'CHORD', 'CIVIL', 'CLAIM', 'CLASH',
    'CLASP', 'CLASS', 'CLEAN', 'CLEAR', 'CLERK', 'CLICK', 'CLIFF', 'CLIMB', 'CLOAK', 'CLOCK',
    'CLOSE', 'CLOTH', 'CLOUD', 'COACH', 'COAST', 'COLOR', 'CORAL', 'COUNT', 'COURT', 'COVER',
    'CRACK', 'CRAFT', 'CRANE', 'CRASH', 'CRAZY', 'CREAM', 'CREEK', 'CREEP', 'CRISP', 'CROSS',
    'CROWD', 'CROWN', 'CRUDE', 'CRUSH', 'CURVE', 'CYCLE', 'DAILY', 'DANCE', 'DRAFT', 'DRAIN',
    'DRAKE', 'DRAMA', 'DRANK', 'DRAWN', 'DREAM', 'DRESS', 'DRIFT', 'DRILL', 'DRINK', 'DRIVE',
    'DRONE', 'EAGLE', 'EARLY', 'EARTH', 'ELDER', 'ELECT', 'ELITE', 'EMPTY', 'ENEMY', 'ENJOY',
    'ENTER', 'ENTRY', 'EQUAL', 'EQUIP', 'ERROR', 'ESSAY', 'EVENT', 'EVERY', 'EXACT', 'EXIST',
    'EXTRA', 'FAITH', 'FALSE', 'FANCY', 'FAULT', 'FAVOR', 'FEAST', 'FIBER', 'FIELD', 'FIFTH',
    'FIFTY', 'FIGHT', 'FINAL', 'FIRST', 'FLAME', 'FLASH', 'FLEET', 'FLOAT', 'FLOOD', 'FLOOR',
    'FLOUR', 'FLUID', 'FLUTE', 'FOCUS', 'FORCE', 'FORTH', 'FORTY', 'FORUM', 'FOUND', 'FRAME',
    'FRESH', 'FRONT', 'FROST', 'FRUIT', 'GIANT', 'GLASS', 'GLOBE', 'GLORY', 'GRACE', 'GRADE',
    'GRAIN', 'GRAND', 'GRANT', 'GRAPE', 'GRAPH', 'GRASP', 'GRASS', 'GRAVE', 'GREAT', 'GREET',
    'GRIEF', 'GRILL', 'GRIND', 'GRIP', 'GROSS', 'GROUP', 'GROVE', 'GUARD', 'GUESS', 'GUIDE',
    'HABIT', 'HAPPY', 'HARSH', 'HASTE', 'HAVEN', 'HEART', 'HEAVY', 'HONEY', 'HONOR', 'HORSE',
    'HOTEL', 'HOUSE', 'HUMAN', 'HUMOR', 'IDEAL', 'IMAGE', 'INDEX', 'INNER', 'INPUT', 'IRONY',
    'ISSUE', 'IVORY', 'JEWEL', 'JOINT', 'JUDGE', 'JUICE', 'KNIFE', 'KNOCK', 'LABEL', 'LABOR',
    'LANCE', 'LARGE', 'LASER', 'LATER', 'LAUGH', 'LAYER', 'LEARN', 'LEASE', 'LEAST', 'LEMON',
    'LEVEL', 'LEVER', 'LIGHT', 'LIMIT', 'LIVER', 'LOCAL', 'LODGE', 'LOGIC', 'LOOSE', 'LOVER',
    'LUCKY', 'LUNCH', 'LUNAR', 'MAGIC', 'MAJOR', 'MAKER', 'MANGO', 'MARCH', 'MATCH', 'MAYBE',
    'MAYOR', 'MEDAL', 'MEDIA', 'MELON', 'MERCY', 'MERIT', 'METAL', 'METER', 'MIDST', 'MIGHT',
    'MINOR', 'MINUS', 'MIXER', 'MODEL', 'MODEM', 'MONEY', 'MONTH', 'MORAL', 'MOTOR', 'MOUNT',
    'MOUSE', 'MOUTH', 'MOVIE', 'MUSIC', 'NAIVE', 'NERVE', 'NIGHT', 'NOBLE', 'NOISE', 'NORTH',
    'NOVEL', 'NURSE', 'OCEAN', 'OFFER', 'OFTEN', 'OLIVE', 'ONSET', 'OPERA', 'ORBIT', 'ORDER',
    'ORGAN', 'OTHER', 'OUTER', 'OXIDE', 'OZONE', 'PAINT', 'PANEL', 'PANIC', 'PAPER', 'PARTY',
    'PASTA', 'PATCH', 'PAUSE', 'PEACE', 'PEACH', 'PEARL', 'PENNY', 'PHASE', 'PHONE', 'PHOTO',
    'PIANO', 'PIECE', 'PILOT', 'PINCH', 'PIXEL', 'PIZZA', 'PLACE', 'PLAIN', 'PLANE', 'PLANT',
    'PLATE', 'PLAZA', 'PLUME', 'POINT', 'POLAR', 'POUND', 'POWER', 'PRICE', 'PRIDE', 'PRIME',
    'PRINT', 'PRIZE', 'PULSE', 'PUPIL', 'QUEEN', 'QUERY', 'QUEST', 'QUICK', 'QUIET', 'QUOTA',
    'RADAR', 'RADIO', 'RAINY', 'RANCH', 'RANGE', 'RAPID', 'RATIO', 'REACH', 'REACT', 'READY',
    'REALM', 'REBEL', 'REFER', 'RELAX', 'RELIC', 'RENEW', 'REPAY', 'RESET', 'RESIN', 'RETRO',
    'RIDER', 'RIDGE', 'RIFLE', 'RIGHT', 'RIVAL', 'RIVER', 'ROBOT', 'ROCKY', 'ROGER', 'ROOFT',
    'ROTOR', 'ROUGE', 'ROUGH', 'ROUND', 'ROUTE', 'ROYAL', 'RULER', 'RUMOR', 'RUSTY', 'SAINT',
    'SALAD', 'SAUCE', 'SCALE', 'SCARE', 'SCENE', 'SCENT', 'SCOPE', 'SCORE', 'SCOUT', 'SCRAP',
    'SEDAN', 'SHADE', 'SHAFT', 'SHAKE', 'SHAME', 'SHAPE', 'SHARE', 'SHARK', 'SHARP', 'SHEEP',
    'SHEER', 'SHEET', 'SHELF', 'SHELL', 'SHIFT', 'SHINE', 'SHINY', 'SHIRT', 'SHOCK', 'SHOOT',
    'SHORE', 'SHORT', 'SHOUT', 'SIGHT', 'SIGMA', 'SILEN', 'SILKY', 'SILLY', 'SINCE', 'SIREN',
    'SKATE', 'SKILL', 'SKULL', 'SLACK', 'SLATE', 'SLEEP', 'SLICE', 'SLIDE', 'SLOPE', 'SMART',
    'SMASH', 'SMELL', 'SMILE', 'SMOKE', 'SNACK', 'SNAKE', 'SOLAR', 'SOLID', 'SOLVE', 'SONIC',
    'SORRY', 'SOUND', 'SOUTH', 'SPACE', 'SPARE', 'SPARK', 'SPEAK', 'SPEED', 'SPELL', 'SPEND',
    'SPICE', 'SPICY', 'SPIKE', 'SPINE', 'SPIRIT', 'SPLIT', 'SPOIL', 'SPOKE', 'SPORT', 'SPRAY',
    'SQUAD', 'STACK', 'STAFF', 'STAGE', 'STAIN', 'STAIR', 'STAKE', 'STALE', 'STAND', 'STARE',
    'START', 'STATE', 'STEAM', 'STEEL', 'STEEP', 'STEER', 'STICK', 'STIFF', 'STILL', 'STOCK',
    'STONE', 'STOOL', 'STORM', 'STORY', 'STRAP', 'STRAW', 'STRAY', 'STUDY', 'STUFF', 'STYLE',
    'SUGAR', 'SUITE', 'SUNNY', 'SUPER', 'SURGE', 'SUSHI', 'SWARM', 'SWEAT', 'SWEET', 'SWIFT',
    'SWING', 'SWORD', 'TABLE', 'TACOS', 'TASTE', 'TEACH', 'THEME', 'THICK', 'THIEF', 'THING',
    'THINK', 'THIRD', 'THORN', 'TIGER', 'TIMER', 'TITLE', 'TOAST', 'TOKEN', 'TOOTH', 'TOPAZ',
    'TORCH', 'TOTAL', 'TOUCH', 'TOWER', 'TOXIC', 'TRACE', 'TRACK', 'TRACT', 'TRADE', 'TRAIL',
    'TRAIN', 'TRAIT', 'TRAMP', 'TRASH', 'TREAT', 'TREND', 'TRIAD', 'TRIAL', 'TRIBE', 'TRICK',
    'TROOP', 'TRUCK', 'TRULY', 'TRUMP', 'TRUNK', 'TRUST', 'TRUTH', 'TULIP', 'TUMOR', 'TUNER',
    'TURBO', 'TUTOR', 'TWIST', 'TYPER', 'ULTRA', 'UNCLE', 'UNDER', 'UNION', 'UNITE', 'UNITY',
    'UPPER', 'UPSET', 'URBAN', 'USAGE', 'VALID', 'VALOR', 'VALUE', 'VALVE', 'VAPOR', 'VAULT',
    'VENUE', 'VERGE', 'VERSE', 'VIGOR', 'VILLA', 'VIRAL', 'VIRUS', 'VISIT', 'VITAL', 'VIVID',
    'VOCAL', 'VOICE', 'VOTER', 'WAGON', 'WASTE', 'WATCH', 'WATER', 'WAVE', 'WEARY', 'WEDGE',
    'WHEAT', 'WHEEL', 'WHERE', 'WHICH', 'WHILE', 'WHITE', 'WHOLE', 'WIDOW', 'WIDTH', 'WINDY',
    'WITCH', 'WOMAN', 'WORLD', 'WORRY', 'WORSE', 'WORST', 'WORTH', 'WOUND', 'WRIST', 'WRITE',
    'WRONG', 'YACHT', 'YEARN', 'YEAST', 'YIELD', 'YOUNG', 'YOUTH', 'ZEBRA', 'ZESTY', 'ZONAL'
  ];

  late final Set<String> _validWordSet;

  void _initValidSets() {
    _validWordSet = <String>{
      ...solutions4,
      ...solutions5,
      ...solutions6,
      ...commonWords,
    };
  }

  /// Checks whether [word] exists in the acceptable dictionary
  bool isValidWord(String word) {
    final clean = word.toUpperCase().trim();
    if (clean.length == 4) {
      return _validWordSet.contains(clean) || solutions4.contains(clean);
    } else if (clean.length == 5) {
      return _validWordSet.contains(clean) || solutions5.contains(clean);
    } else if (clean.length == 6) {
      return _validWordSet.contains(clean) || solutions6.contains(clean);
    }
    return _validWordSet.contains(clean);
  }

  /// Returns a random solution for the given [length] (4, 5, or 6)
  String getRandomSolution(int length) {
    final rand = Random();
    if (length == 4) {
      return solutions4[rand.nextInt(solutions4.length)];
    } else if (length == 6) {
      return solutions6[rand.nextInt(solutions6.length)];
    }
    return solutions5[rand.nextInt(solutions5.length)];
  }

  /// Daily Seeded Solution: Deterministic word for the given UTC date
  String getDailySolution(DateTime dateUtc) {
    // Generate a consistent integer seed from year, month, and day
    final seed = (dateUtc.year * 10000) + (dateUtc.month * 100) + dateUtc.day;
    final rand = Random(seed);
    return solutions5[rand.nextInt(solutions5.length)];
  }

  /// Word Connect / Radial Anagram Levels
  static const List<WordConnectLevel> wordConnectLevels = [
    WordConnectLevel(
      level: 1,
      wheelLetters: ['A', 'R', 'T', 'S'],
      targetWords: ['ART', 'RAT', 'TAR', 'STAR', 'RATS', 'ARTS'],
      primaryWord: 'STAR',
    ),
    WordConnectLevel(
      level: 2,
      wheelLetters: ['E', 'A', 'S', 'T'],
      targetWords: ['TEA', 'EAT', 'SEA', 'SET', 'EAST', 'SEAT'],
      primaryWord: 'EAST',
    ),
    WordConnectLevel(
      level: 3,
      wheelLetters: ['P', 'O', 'S', 'T'],
      targetWords: ['TOP', 'POT', 'SPOT', 'STOP', 'POST', 'TOPS'],
      primaryWord: 'POST',
    ),
    WordConnectLevel(
      level: 4,
      wheelLetters: ['L', 'E', 'A', 'P'],
      targetWords: ['ALE', 'APE', 'PAL', 'PEA', 'PALE', 'LEAP', 'PLEA'],
      primaryWord: 'LEAP',
    ),
    WordConnectLevel(
      level: 5,
      wheelLetters: ['S', 'M', 'I', 'L', 'E'],
      targetWords: ['SLIM', 'LIME', 'MILE', 'SEMI', 'SMILE', 'SLIME'],
      primaryWord: 'SMILE',
    ),
    WordConnectLevel(
      level: 6,
      wheelLetters: ['P', 'L', 'A', 'N', 'T'],
      targetWords: ['PLAN', 'PLAT', 'PANT', 'PLAN', 'PLANT'],
      primaryWord: 'PLANT',
    ),
    WordConnectLevel(
      level: 7,
      wheelLetters: ['S', 'P', 'A', 'R', 'K'],
      targetWords: ['PARK', 'SPARK', 'SPAR', 'RAPS', 'RASK'],
      primaryWord: 'SPARK',
    ),
  ];

  WordConnectLevel getWordConnectLevel(int levelNumber) {
    final index = (levelNumber - 1) % wordConnectLevels.length;
    return wordConnectLevels[index];
  }

  /// 3 Clues -> 1 Solution Association Puzzles
  static const List<AssociationPuzzle> associationPuzzles = [
    AssociationPuzzle(
      clues: ['SKI', 'SNOW', 'COLD'],
      solution: 'WINTER',
      bankLetters: ['W', 'I', 'N', 'T', 'E', 'R', 'S', 'O', 'A', 'L', 'K', 'M'],
    ),
    AssociationPuzzle(
      clues: ['SAND', 'WAVES', 'SUN'],
      solution: 'BEACH',
      bankLetters: ['B', 'E', 'A', 'C', 'H', 'S', 'U', 'N', 'D', 'L', 'O', 'T'],
    ),
    AssociationPuzzle(
      clues: ['HONEY', 'STRIPES', 'BUZZ'],
      solution: 'BEE',
      bankLetters: ['B', 'E', 'E', 'F', 'L', 'Y', 'A', 'N', 'T', 'W', 'O', 'R'],
    ),
    AssociationPuzzle(
      clues: ['NIGHT', 'STARS', 'GLOW'],
      solution: 'MOON',
      bankLetters: ['M', 'O', 'O', 'N', 'S', 'U', 'N', 'S', 'K', 'Y', 'L', 'T'],
    ),
    AssociationPuzzle(
      clues: ['FLOUR', 'OVEN', 'SLICE'],
      solution: 'BREAD',
      bankLetters: ['B', 'R', 'E', 'A', 'D', 'C', 'A', 'K', 'E', 'P', 'I', 'E'],
    ),
    AssociationPuzzle(
      clues: ['REEF', 'OCEAN', 'FINS'],
      solution: 'SHARK',
      bankLetters: ['S', 'H', 'A', 'R', 'K', 'F', 'I', 'S', 'H', 'B', 'A', 'T'],
    ),
    AssociationPuzzle(
      clues: ['PEDAL', 'GEARS', 'RIDE'],
      solution: 'BIKE',
      bankLetters: ['B', 'I', 'K', 'E', 'C', 'A', 'R', 'B', 'U', 'S', 'T', 'O'],
    ),
    AssociationPuzzle(
      clues: ['CROWN', 'THRONE', 'CASTLE'],
      solution: 'KING',
      bankLetters: ['K', 'I', 'N', 'G', 'Q', 'U', 'E', 'E', 'N', 'P', 'R', 'I'],
    ),
  ];

  AssociationPuzzle getAssociationPuzzle(int index) {
    return associationPuzzles[index % associationPuzzles.length];
  }
}
