import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SfxType {
  swap,
  match,
  cascade,
  overchargeDetonate,
  quantumClear,
  firewallHit,
  levelWin,
  levelLoss,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!_isMusicEnabled) {
      _bgmPlayer.pause();
    } else {
      playBgm();
    }
  }

  Future<void> playBgm() async {
    if (!_isMusicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/synthwave_bgm.mp3'), volume: 0.4);
    } catch (e) {
      debugPrint('AudioService: BGM play error (fallback audio mode active): $e');
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('AudioService: BGM pause error: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (_isMusicEnabled) {
      try {
        await _bgmPlayer.resume();
      } catch (e) {
        debugPrint('AudioService: BGM resume error: $e');
      }
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('AudioService: BGM stop error: $e');
    }
  }

  Future<void> playSfx(SfxType type) async {
    if (!_isSoundEnabled) return;
    String fileName;
    switch (type) {
      case SfxType.swap:
        fileName = 'sfx_swap.wav';
        break;
      case SfxType.match:
        fileName = 'sfx_match.wav';
        break;
      case SfxType.cascade:
        fileName = 'sfx_cascade.wav';
        break;
      case SfxType.overchargeDetonate:
        fileName = 'sfx_overcharge.wav';
        break;
      case SfxType.quantumClear:
        fileName = 'sfx_quantum.wav';
        break;
      case SfxType.firewallHit:
        fileName = 'sfx_firewall.wav';
        break;
      case SfxType.levelWin:
        fileName = 'sfx_win.wav';
        break;
      case SfxType.levelLoss:
        fileName = 'sfx_loss.wav';
        break;
    }

    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: 0.8);
    } catch (e) {
      debugPrint('AudioService: SFX error for $fileName: $e');
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
