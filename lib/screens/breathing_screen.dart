// ============================================================
// ДАСГАЛЫН ДЭЛГЭЦ
// Циклүүдийг дараалан ажиллуулж, үлдсэн хугацааг харуулна
// Цикл бүр: нэр зарлах → секунд тоолох → дуугаргах
// ============================================================
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/cycle_config.dart';
import '../services/sound_manager.dart';
import 'setup_screen.dart';

class BreathingScreen extends StatefulWidget {
  final List<CycleConfig> cycles; // Циклүүдийн жагсаалт
  final int finishMinutes; // Нийт дасгалын хугацаа (минутаар)

  const BreathingScreen({
    super.key,
    required this.cycles,
    required this.finishMinutes,
  });

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // --- Төлөв ---
  bool _isRunning = false;
  String _currentPhase = 'idle'; // idle | speaking | counting
  int _phaseSecondsLeft = 0; // Үлдсэн секунд
  int _totalTimeRemaining = 0; // Нийт үлдсэн хугацаа
  int _currentCycleIndex = 0; // Одоогийн циклийн индекс
  int _currentCycle = 0; // Одоогийн циклийн дугаар (1-ээс эхлэн)

  // --- Таймерууд ---
  Timer? _phaseTimer; // Циклийн фазын таймер
  Timer? _mainTimer; // Нийт хугацааны таймер

  // --- Анимейшн ---
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // --- TTS (Text-to-Speech) ---
  FlutterTts? _flutterTts;

  // --- Дуу ---
  final SoundManager _soundManager = SoundManager();

  // Дэвсгэр рүү шилжихэд түр зогсоох
  bool _wasRunningBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Анимейшн эхлүүлэх
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _totalTimeRemaining = widget.finishMinutes * 60;
    _initTts();
    _soundManager.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phaseTimer?.cancel();
    _mainTimer?.cancel();
    _animController.dispose();
    _flutterTts?.stop();
    _soundManager.dispose();
    super.dispose();
  }

  // --- Аппын төлөв өөрчлөгдөхөд (background/foreground) ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasRunningBeforePause = _isRunning;
      if (_isRunning) _pauseTimers();
    } else if (state == AppLifecycleState.resumed) {
      if (_wasRunningBeforePause) _resumeTimers();
      setState(() {});
    }
  }

  /// Таймеруудыг түр зогсоох
  void _pauseTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _mainTimer?.cancel();
    _mainTimer = null;
    _animController.stop();
  }

  /// Таймеруудыг үргэлжлүүлэх
  void _resumeTimers() {
    if (!_isRunning) return;

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining > 0) {
        setState(() => _totalTimeRemaining--);
      }
    });

    if (_currentPhase == 'counting' && _phaseSecondsLeft > 0) {
      _animController.duration = Duration(seconds: _phaseSecondsLeft);
      _animController.forward(from: 0);

      _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_phaseSecondsLeft > 0) {
          setState(() => _phaseSecondsLeft--);
        } else {
          timer.cancel();
          _phaseTimer = null;
        }
      });
    }
  }

  // --- TTS эхлүүлэх ---
  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('mn-MN');
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS init error: $e');
      _flutterTts = null;
    }
  }

  /// TTS-ээр текст хэлэх
  Future<void> _speak(String text) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Фазын төлөвийг тохируулах
  void _setPhase(String phase, int seconds) {
    setState(() {
      _currentPhase = phase;
      _phaseSecondsLeft = seconds;

      if (phase == 'counting') {
        _animController.duration = Duration(seconds: seconds);
        _animController.forward(from: 0);
      } else if (phase == 'idle') {
        _animController.stop();
        _animController.value = 0;
      } else {
        _animController.stop();
      }
    });
  }

  /// Фазыг эхлүүлэх (секунд тоолох)
  Future<void> _startPhase(String phase, int duration) async {
    _setPhase(phase, duration);
    _soundManager.playBeepShort();

    final completer = Completer<void>();
    int remaining = duration;

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      setState(() => _phaseSecondsLeft = remaining);

      if (remaining <= 0) {
        timer.cancel();
        _phaseTimer = null;
        completer.complete();
      }
    });

    return completer.future;
  }

  /// Дасгал эхлүүлэх
  Future<void> _startBreathing() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _currentCycleIndex = 0;
      _currentCycle = 0;
      _totalTimeRemaining = widget.finishMinutes * 60;
    });

    // Нийт хугацааны таймер
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining > 0) {
        setState(() => _totalTimeRemaining--);
      }
    });

    // Циклүүдийг дараалан ажиллуулах
    while (_isRunning) {
      if (_totalTimeRemaining <= 0) break;

      final cycleConfig = widget.cycles[_currentCycleIndex];
      setState(() => _currentCycle = _currentCycleIndex + 1);

      // 1. Циклийн нэрийг TTS-ээр хэлэх
      setState(() => _currentPhase = 'speaking');
      _soundManager.playBeepStart();
      await _speak(cycleConfig.name);
      if (!_isRunning) break;

      // Богино завсарлага
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isRunning) break;

      // 2. Секунд тоолох
      await _startPhase('counting', cycleConfig.durationSeconds);
      if (!_isRunning) break;

      // 3. Цикл дууссан дохио
      _soundManager.playBeepEnd();

      // Дараагийн цикл рүү шилжих
      _currentCycleIndex = (_currentCycleIndex + 1) % widget.cycles.length;
    }

    _stopBreathing(completed: true);
  }

  /// Дасгалыг зогсоох
  void _stopBreathing({bool completed = false}) {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _mainTimer?.cancel();
    _mainTimer = null;

    setState(() {
      _isRunning = false;
      _wasRunningBeforePause = false;
      if (completed) {
        _currentPhase = 'idle';
        _soundManager.playBeepComplete();
      }
    });
  }

  // --- Туслах функцууд ---

  String _getPhaseText() {
    switch (_currentPhase) {
      case 'speaking':
        return '🎙️ Цикл зарлаж байна...';
      case 'counting':
        return '⏱️ Тоолж байна...';
      case 'idle':
        return _isRunning ? '' : 'Бэлэн';
      default:
        return '';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 'speaking':
        return const Color(0xFF667eea);
      case 'counting':
        return const Color(0xFF43e97b);
      default:
        return const Color(0xFFe0e5ff);
    }
  }

  String _getCurrentCycleName() {
    if (_currentCycleIndex >= 0 &&
        _currentCycleIndex < widget.cycles.length) {
      return widget.cycles[_currentCycleIndex].name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = min(screenWidth * 0.5, 200.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌬️ Timer'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Одоогийн циклийн нэр
              if (_isRunning && _currentCycle > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔄 ${_getCurrentCycleName()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF667eea),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Амьсгалын тойрог (анимейшнтэй)
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _currentPhase == 'counting'
                        ? _scaleAnimation.value
                        : 1.0,
                    child: Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getPhaseColor(),
                            _getPhaseColor().withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getPhaseColor().withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getPhaseText(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 8, color: Colors.black26),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          if (_phaseSecondsLeft > 0)
                            Text(
                              '$_phaseSecondsLeft',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(blurRadius: 8, color: Colors.black26),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Прогресс бар
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.finishMinutes > 0
                        ? (widget.finishMinutes * 60 - _totalTimeRemaining) /
                            (widget.finishMinutes * 60)
                        : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Удирдлагын товчнууд
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isRunning) {
                          _stopBreathing();
                        } else {
                          _startBreathing();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _isRunning
                            ? const Color(0xFFf5576c)
                            : const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        _isRunning ? '⏹ Зогсоох' : '▶ Эхлэх',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRunning
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetupScreen(),
                                ),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '⟲ Шинэчлэх',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Статистик
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Цикл: $_currentCycle / ${widget.cycles.length}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Үлдсэн: ${_totalTimeRemaining ~/ 60}:${(_totalTimeRemaining % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Циклийн жагсаалт (зогссон үед харуулах)
              if (!_isRunning)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFf8f9ff),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Циклүүд',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(widget.cycles.length, (index) {
                        final cycle = widget.cycles[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index < widget.cycles.length - 1 ? 6 : 0,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF667eea),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cycle.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${cycle.durationSeconds}с',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
