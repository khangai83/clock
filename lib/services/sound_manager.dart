// ============================================================
// Дуу удирдах сервис
// Цикл эхлэх, дуусах, богино дохио өгөх зэрэг дуунуудыг удирдана
// Хэрэв дуу тоглуулах боломжгүй бол чичиргээгээр солино
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // Singleton загвар - нэг л удаа үүсгэнэ
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  AudioPlayer? _player;
  bool _initialized = false;

  /// Дуу тоглуулагчийг эхлүүлнэ
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _player = AudioPlayer();
    } catch (e) {
      debugPrint('AudioPlayer init error: $e');
    }
  }

  /// Богино "бип" дуу гаргах (секунд тоолох үед)
  Future<void> playBeepShort() async {
    if (_player == null) {
      HapticFeedback.lightImpact();
      return;
    }
    try {
      await _player!.stop();
      await _player!.play(AssetSource('sounds/beep_short.wav'));
    } catch (e) {
      debugPrint('Beep error: $e');
      HapticFeedback.lightImpact();
    }
  }

  /// Цикл эхлэх дохио (2 удаа дуугарна)
  Future<void> playBeepStart() async {
    if (_player == null) {
      HapticFeedback.heavyImpact();
      return;
    }
    try {
      await _player!.stop();
      await _player!.play(AssetSource('sounds/beep_start.wav'));
      // Хоёр дахь удаагаа дуугаргах
      Future.delayed(const Duration(milliseconds: 200), () async {
        try {
          await _player!.play(AssetSource('sounds/beep_start.wav'));
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Beep start error: $e');
      HapticFeedback.heavyImpact();
    }
  }

  /// Цикл дуусах дохио
  Future<void> playBeepEnd() async {
    if (_player == null) {
      HapticFeedback.heavyImpact();
      return;
    }
    try {
      await _player!.stop();
      await _player!.play(AssetSource('sounds/beep_end.wav'));
    } catch (e) {
      debugPrint('Beep end error: $e');
      HapticFeedback.heavyImpact();
    }
  }

  /// Бүх цикл дууссан дохио
  Future<void> playBeepComplete() async {
    if (_player == null) {
      HapticFeedback.heavyImpact();
      return;
    }
    try {
      await _player!.stop();
      await _player!.play(AssetSource('sounds/beep_complete.wav'));
    } catch (e) {
      debugPrint('Beep complete error: $e');
      HapticFeedback.heavyImpact();
    }
  }

  /// Цэвэрлэх
  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
