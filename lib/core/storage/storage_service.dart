import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box? _userBox;
  SharedPreferences? _prefs;

  static const String userBoxName = 'user_profile_box';

  // Keys
  static const String keyDataBits = 'data_bits';
  static const String keyUnlockedLevel = 'unlocked_level';
  static const String keyEquippedSkin = 'equipped_skin';
  static const String keyEquippedTheme = 'equipped_theme';
  static const String keyEndlessHighScore = 'endless_high_score';
  static const String keyEndlessMaxCombo = 'endless_max_combo';
  static const String keyEndlessTotalNodes = 'endless_total_nodes';

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _userBox = await Hive.openBox(userBoxName);
    } catch (e) {
      debugPrint('StorageService: Hive init failed, falling back to SharedPreferences: $e');
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // Data Bits Balance
  int getDataBits() {
    if (_userBox != null) {
      return _userBox!.get(keyDataBits, defaultValue: 250);
    }
    return _prefs?.getInt(keyDataBits) ?? 250;
  }

  Future<void> saveDataBits(int bits) async {
    if (_userBox != null) {
      await _userBox!.put(keyDataBits, bits);
    } else {
      await _prefs?.setInt(keyDataBits, bits);
    }
  }

  // Campaign Progress
  int getUnlockedLevel() {
    if (_userBox != null) {
      return _userBox!.get(keyUnlockedLevel, defaultValue: 1);
    }
    return _prefs?.getInt(keyUnlockedLevel) ?? 1;
  }

  Future<void> saveUnlockedLevel(int levelId) async {
    int current = getUnlockedLevel();
    if (levelId > current) {
      if (_userBox != null) {
        await _userBox!.put(keyUnlockedLevel, levelId);
      } else {
        await _prefs?.setInt(keyUnlockedLevel, levelId);
      }
    }
  }

  int getLevelStars(int levelId) {
    String key = 'level_stars_$levelId';
    if (_userBox != null) {
      return _userBox!.get(key, defaultValue: 0);
    }
    return _prefs?.getInt(key) ?? 0;
  }

  Future<void> saveLevelStars(int levelId, int stars) async {
    String key = 'level_stars_$levelId';
    int existing = getLevelStars(levelId);
    if (stars > existing) {
      if (_userBox != null) {
        await _userBox!.put(key, stars);
      } else {
        await _prefs?.setInt(key, stars);
      }
    }
  }

  // Skins & Themes
  List<String> getUnlockedSkins() {
    if (_userBox != null) {
      List<dynamic> list = _userBox!.get('unlocked_skins', defaultValue: ['chip_default']);
      return list.cast<String>();
    }
    return _prefs?.getStringList('unlocked_skins') ?? ['chip_default'];
  }

  Future<void> unlockSkin(String skinId) async {
    List<String> skins = getUnlockedSkins();
    if (!skins.contains(skinId)) {
      skins.add(skinId);
      if (_userBox != null) {
        await _userBox!.put('unlocked_skins', skins);
      } else {
        await _prefs?.setStringList('unlocked_skins', skins);
      }
    }
  }

  String getEquippedSkin() {
    if (_userBox != null) {
      return _userBox!.get(keyEquippedSkin, defaultValue: 'chip_default');
    }
    return _prefs?.getString(keyEquippedSkin) ?? 'chip_default';
  }

  Future<void> setEquippedSkin(String skinId) async {
    if (_userBox != null) {
      await _userBox!.put(keyEquippedSkin, skinId);
    } else {
      await _prefs?.setString(keyEquippedSkin, skinId);
    }
  }

  String getEquippedTheme() {
    if (_userBox != null) {
      return _userBox!.get(keyEquippedTheme, defaultValue: 'theme_vaporwave');
    }
    return _prefs?.getString(keyEquippedTheme) ?? 'theme_vaporwave';
  }

  Future<void> setEquippedTheme(String themeId) async {
    if (_userBox != null) {
      await _userBox!.put(keyEquippedTheme, themeId);
    } else {
      await _prefs?.setString(keyEquippedTheme, themeId);
    }
  }

  // Endless Mode High Scores
  int getEndlessHighScore() {
    if (_userBox != null) {
      return _userBox!.get(keyEndlessHighScore, defaultValue: 0);
    }
    return _prefs?.getInt(keyEndlessHighScore) ?? 0;
  }

  Future<void> saveEndlessHighScore(int score) async {
    int current = getEndlessHighScore();
    if (score > current) {
      if (_userBox != null) {
        await _userBox!.put(keyEndlessHighScore, score);
      } else {
        await _prefs?.setInt(keyEndlessHighScore, score);
      }
    }
  }

  int getEndlessMaxCombo() {
    if (_userBox != null) {
      return _userBox!.get(keyEndlessMaxCombo, defaultValue: 0);
    }
    return _prefs?.getInt(keyEndlessMaxCombo) ?? 0;
  }

  Future<void> saveEndlessMaxCombo(int combo) async {
    int current = getEndlessMaxCombo();
    if (combo > current) {
      if (_userBox != null) {
        await _userBox!.put(keyEndlessMaxCombo, combo);
      } else {
        await _prefs?.setInt(keyEndlessMaxCombo, combo);
      }
    }
  }
}
