import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const BreathingApp());
}

class BreathingApp extends StatelessWidget {
  const BreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}

// ============================================================
// SETUP SCREEN - Configure cycles and finish time
// ============================================================
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  final _cycleCountController = TextEditingController(text: '3');
  final _finishTimeController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cycleCountController.dispose();
    _finishTimeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _onNext() {
    final cycles = int.tryParse(_cycleCountController.text) ?? 3;
    final minutes = int.tryParse(_finishTimeController.text) ?? 5;
    if (cycles < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Циклийн тоо хамгийн багадаа 1 байх ёстой')),
      );
      return;
    }
    if (minutes < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дуусах хугацаа хамгийн багадаа 1 минут байх ёстой')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CycleSetupScreen(
          cycleCount: cycles,
          finishMinutes: minutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                '🌬️ Timer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Дасгалын тохиргоо',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // Cycle count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFf8f9ff),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🔄', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Циклийн тоо (Cycle)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Хэдэн циклтэй байх вэ?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.remove,
                          const Color(0xFFef4444),
                          const Color(0xFFfee2e2),
                          onPressed: () {
                            final v = int.tryParse(_cycleCountController.text) ?? 3;
                            if (v > 1) {
                              _cycleCountController.text = '${v - 1}';
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cycleCountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.add,
                          const Color(0xFF22c55e),
                          const Color(0xFFdcfce7),
                          onPressed: () {
                            final v = int.tryParse(_cycleCountController.text) ?? 3;
                            if (v < 50) {
                              _cycleCountController.text = '${v + 1}';
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Finish time
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFf8f9ff),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⏱️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Дуусах хугацаа (Finish Time)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Нийт хэдэн минут үргэлжлэх вэ?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.remove,
                          const Color(0xFFef4444),
                          const Color(0xFFfee2e2),
                          onPressed: () {
                            final v = int.tryParse(_finishTimeController.text) ?? 5;
                            if (v > 1) {
                              _finishTimeController.text = '${v - 1}';
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _finishTimeController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.add,
                          const Color(0xFF22c55e),
                          const Color(0xFFdcfce7),
                          onPressed: () {
                            final v = int.tryParse(_finishTimeController.text) ?? 5;
                            if (v < 120) {
                              _finishTimeController.text = '${v + 1}';
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Циклүүдээ тохируулах →',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

// ============================================================
// CYCLE SETUP SCREEN - Configure each cycle's name and duration
// ============================================================
class CycleSetupScreen extends StatefulWidget {
  final int cycleCount;
  final int finishMinutes;

  const CycleSetupScreen({
    super.key,
    required this.cycleCount,
    required this.finishMinutes,
  });

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen> with WidgetsBindingObserver {
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _durationControllers;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nameControllers = List.generate(
      widget.cycleCount,
      (i) => TextEditingController(text: 'Цикл ${i + 1}'),
    );
    _durationControllers = List.generate(
      widget.cycleCount,
      (i) => TextEditingController(text: '60'),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _durationControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _onStart() {
    // Validate
    final cycles = <CycleConfig>[];
    for (int i = 0; i < widget.cycleCount; i++) {
      final name = _nameControllers[i].text.trim();
      final duration = int.tryParse(_durationControllers[i].text) ?? 60;
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Цикл ${i + 1}-ийн нэр хоосон байна')),
        );
        return;
      }
      if (duration < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Цикл ${i + 1}-ийн үргэлжлэх хугацаа хамгийн багадаа 1 секунд байх ёстой',
            ),
          ),
        );
        return;
      }
      cycles.add(CycleConfig(name: name, durationSeconds: duration));
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BreathingScreen(
          cycles: cycles,
          finishMinutes: widget.finishMinutes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Цикл тохируулах (${_currentPage + 1}/${widget.cycleCount})',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Page indicator dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.cycleCount, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF667eea)
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),

          // Cycle cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemCount: widget.cycleCount,
              itemBuilder: (context, index) {
                return _buildCycleCard(index, isDark);
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '← Өмнөх',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < widget.cycleCount - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _onStart();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentPage < widget.cycleCount - 1
                          ? 'Дараах →'
                          : '▶ Эхлэх',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard(int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFf8f9ff),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF667eea).withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cycle number
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cycle name
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Циклийн нэр',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameControllers[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Циклийн нэр оруулах',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              // Cycle duration
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Үргэлжлэх хугацаа (секунд)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildIconButton(
                    Icons.remove,
                    const Color(0xFFef4444),
                    const Color(0xFFfee2e2),
                    onPressed: () {
                      final v =
                          int.tryParse(_durationControllers[index].text) ?? 60;
                      if (v > 1) {
                        _durationControllers[index].text = '${v - 1}';
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _durationControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildIconButton(
                    Icons.add,
                    const Color(0xFF22c55e),
                    const Color(0xFFdcfce7),
                    onPressed: () {
                      final v =
                          int.tryParse(_durationControllers[index].text) ?? 60;
                      if (v < 600) {
                        _durationControllers[index].text = '${v + 5}';
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Энэ циклэд хэдэн секунд зарцуулах вэ?',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

// ============================================================
// CYCLE CONFIG DATA MODEL
// ============================================================
class CycleConfig {
  final String name;
  final int durationSeconds;

  const CycleConfig({
    required this.name,
    required this.durationSeconds,
  });
}

// ============================================================
// SOUND MANAGER - Handles all audio beep sounds
// ============================================================
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  AudioPlayer? _player;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _player = AudioPlayer();
    } catch (e) {
      debugPrint('AudioPlayer init error: $e');
    }
  }

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

  Future<void> playBeepStart() async {
    if (_player == null) {
      HapticFeedback.heavyImpact();
      return;
    }
    try {
      await _player!.stop();
      await _player!.play(AssetSource('sounds/beep_start.wav'));
      // Play twice for emphasis
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

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}

// ============================================================
// BREATHING SCREEN - Main exercise screen
// ============================================================
class BreathingScreen extends StatefulWidget {
  final List<CycleConfig> cycles;
  final int finishMinutes;

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
  // State
  bool _isRunning = false;
  String _currentPhase = 'idle'; // idle, speaking, counting
  int _phaseSecondsLeft = 0;
  int _totalTimeRemaining = 0;
  int _currentCycleIndex = 0;
  int _currentCycle = 0;

  // Timers
  Timer? _phaseTimer;
  Timer? _mainTimer;

  // Animation
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // TTS (lazy initialization to avoid crashes on unsupported devices)
  FlutterTts? _flutterTts;

  // Sound
  final SoundManager _soundManager = SoundManager();

  // Track if we were running before going to background
  bool _wasRunningBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going to background - pause timers
      _wasRunningBeforePause = _isRunning;
      if (_isRunning) {
        _pauseTimers();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App is coming back to foreground
      if (_wasRunningBeforePause) {
        // Resume timers if they were running
        _resumeTimers();
      }
      setState(() {});
    }
  }

  void _pauseTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _mainTimer?.cancel();
    _mainTimer = null;
    _animController.stop();
  }

  void _resumeTimers() {
    if (!_isRunning) return;

    // Resume main countdown timer
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining > 0) {
        setState(() {
          _totalTimeRemaining--;
        });
      }
    });

    // Resume phase timer if we're in counting phase
    if (_currentPhase == 'counting' && _phaseSecondsLeft > 0) {
      _animController.duration = Duration(seconds: _phaseSecondsLeft);
      _animController.forward(from: 0);

      _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_phaseSecondsLeft > 0) {
          setState(() {
            _phaseSecondsLeft--;
          });
        } else {
          timer.cancel();
          _phaseTimer = null;
        }
      });
    }
  }

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

  Future<void> _speak(String text) async {
    if (_flutterTts == null) return;
    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

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

  Future<void> _startPhase(String phase, int duration) async {
    _setPhase(phase, duration);
    _soundManager.playBeepShort();

    final completer = Completer<void>();
    int remaining = duration;

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      setState(() {
        _phaseSecondsLeft = remaining;
      });

      if (remaining <= 0) {
        timer.cancel();
        _phaseTimer = null;
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _startBreathing() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _currentCycleIndex = 0;
      _currentCycle = 0;
      _totalTimeRemaining = widget.finishMinutes * 60;
    });

    // Main countdown timer
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining > 0) {
        setState(() {
          _totalTimeRemaining--;
        });
      }
    });

    // Start breathing cycles
    while (_isRunning) {
      if (_totalTimeRemaining <= 0) break;

      // Get current cycle config
      final cycleConfig = widget.cycles[_currentCycleIndex];
      setState(() {
        _currentCycle = _currentCycleIndex + 1;
      });

      // --- SPEAK CYCLE NAME ---
      setState(() {
        _currentPhase = 'speaking';
      });
      _soundManager.playBeepStart();
      await _speak(cycleConfig.name);
      if (!_isRunning) break;

      // Small pause after speaking
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isRunning) break;

      // --- COUNTDOWN PHASE (just count seconds) ---
      await _startPhase('counting', cycleConfig.durationSeconds);
      if (!_isRunning) break;

      // --- CYCLE END SOUND ---
      _soundManager.playBeepEnd();

      // Move to next cycle
      _currentCycleIndex = (_currentCycleIndex + 1) % widget.cycles.length;
    }

    _stopBreathing(completed: true);
  }

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
    if (_currentCycleIndex >= 0 && _currentCycleIndex < widget.cycles.length) {
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
              // Current cycle name
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

              // Breathing Circle
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
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black26,
                                ),
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
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black26,
                                  ),
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

              // Progress Bar
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

              // Controls
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

              // Stats
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

              // Cycle list
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
                            bottom: index < widget.cycles.length - 1 ? 6 : 0,
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
