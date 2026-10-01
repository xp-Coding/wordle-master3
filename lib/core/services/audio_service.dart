import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum GameSfx {
  click,
  flip,
  error,
  booster,
  win,
  coin,
  strike,
  spin,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isSoundEnabled = true;
  double _volume = 0.8;
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final Map<GameSfx, Uint8List> _pcmCache = {};

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  Future<void> init({bool soundEnabled = true}) async {
    _isSoundEnabled = soundEnabled;
    try {
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      // Pre-synthesize PCM sound waves in memory for low-latency playback
      _prewarmSynthesizer();
    } catch (e) {
      debugPrint('AudioService init note: $e');
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_volume);
  }

  void _prewarmSynthesizer() {
    _pcmCache[GameSfx.click] = _generateTonePcm(freq: 800, durationMs: 40, attack: 0.1, decay: 0.8);
    _pcmCache[GameSfx.flip] = _generateTonePcm(freq: 520, durationMs: 75, attack: 0.2, decay: 0.6);
    _pcmCache[GameSfx.error] = _generateBuzzPcm(durationMs: 250);
    _pcmCache[GameSfx.booster] = _generateChimePcm(durationMs: 350);
    _pcmCache[GameSfx.win] = _generateFanfarePcm(durationMs: 800);
    _pcmCache[GameSfx.coin] = _generateCoinPcm(durationMs: 120);
    _pcmCache[GameSfx.strike] = _generateBuzzPcm(durationMs: 180);
    _pcmCache[GameSfx.spin] = _generateTonePcm(freq: 640, durationMs: 30, attack: 0.1, decay: 0.8);
  }

  /// Play sound effect with low latency
  Future<void> playSfx(GameSfx sfx) async {
    if (!_isSoundEnabled) return;
    try {
      final pcmBytes = _pcmCache[sfx] ?? _pcmCache[GameSfx.click];
      if (pcmBytes != null) {
        await _sfxPlayer.stop();
        await _sfxPlayer.play(BytesSource(pcmBytes), volume: _volume);
      }
    } catch (e) {
      debugPrint('Audio playback handled gracefully: $e');
    }
  }

  // Fast procedural WAV PCM generator (16-bit Mono, 22050 Hz)
  Uint8List _generateTonePcm({
    required double freq,
    required int durationMs,
    double attack = 0.1,
    double decay = 0.5,
  }) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final pcmData = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      
      // Envelope
      double env = 1.0;
      if (progress < attack) {
        env = progress / attack;
      } else {
        env = 1.0 - ((progress - attack) / (1.0 - attack));
      }

      final sample = (sin(2 * pi * freq * t) * env * 24000).toInt();
      pcmData[i] = sample.clamp(-32768, 32767);
    }

    return _createWavHeader(pcmData, sampleRate);
  }

  Uint8List _generateBuzzPcm({required int durationMs}) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final pcmData = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = 1.0 - (i / numSamples);
      // Low square/saw-like harmonic buzz
      final wave = (sin(2 * pi * 140 * t) > 0 ? 1.0 : -1.0) * 0.7 +
                   (sin(2 * pi * 280 * t) * 0.3);
      pcmData[i] = (wave * env * 22000).toInt().clamp(-32768, 32767);
    }

    return _createWavHeader(pcmData, sampleRate);
  }

  Uint8List _generateChimePcm({required int durationMs}) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final pcmData = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final env = pow(1.0 - (i / numSamples), 1.5).toDouble();
      // Dual resonant bell chime (E6 + B6)
      final wave = sin(2 * pi * 1318.51 * t) * 0.6 + sin(2 * pi * 1975.53 * t) * 0.4;
      pcmData[i] = (wave * env * 25000).toInt().clamp(-32768, 32767);
    }

    return _createWavHeader(pcmData, sampleRate);
  }

  Uint8List _generateCoinPcm({required int durationMs}) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final pcmData = Int16List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = i / numSamples;
      final freq = progress < 0.5 ? 987.77 : 1318.51; // B5 to E6
      final env = 1.0 - progress;
      final wave = sin(2 * pi * freq * t);
      pcmData[i] = (wave * env * 26000).toInt().clamp(-32768, 32767);
    }

    return _createWavHeader(pcmData, sampleRate);
  }

  Uint8List _generateFanfarePcm({required int durationMs}) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final pcmData = Int16List(numSamples);

    // Arpeggio notes: C5 (523), E5 (659), G5 (784), C6 (1046)
    final notes = [523.25, 659.25, 783.99, 1046.50];
    final segmentLength = numSamples / 4;

    for (int i = 0; i < numSamples; i++) {
      final segment = (i / segmentLength).floor().clamp(0, 3);
      final freq = notes[segment];
      final t = i / sampleRate;
      final segmentProgress = (i % segmentLength) / segmentLength;
      final env = 1.0 - (segmentProgress * 0.7);
      final wave = sin(2 * pi * freq * t) * 0.8 + sin(4 * pi * freq * t) * 0.2;
      pcmData[i] = (wave * env * 25000).toInt().clamp(-32768, 32767);
    }

    return _createWavHeader(pcmData, sampleRate);
  }

  Uint8List _createWavHeader(Int16List pcmSamples, int sampleRate) {
    final numChannels = 1;
    final bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final subChunk2Size = pcmSamples.length * 2;
    final chunkSize = 36 + subChunk2Size;

    final buffer = ByteData(44 + subChunk2Size);

    // RIFF chunk descriptor
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, chunkSize, Endian.little);
    buffer.setUint8(8, 0x57);  // W
    buffer.setUint8(9, 0x41);  // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // "fmt " sub-chunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6D); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little); // Subchunk1Size for PCM
    buffer.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
    buffer.setUint16(22, numChannels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, blockAlign, Endian.little);
    buffer.setUint16(34, bitsPerSample, Endian.little);

    // "data" sub-chunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, subChunk2Size, Endian.little);

    // Write audio samples
    for (int i = 0; i < pcmSamples.length; i++) {
      buffer.setInt16(44 + (i * 2), pcmSamples[i], Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
