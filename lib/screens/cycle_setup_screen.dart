// ============================================================
// ЦИКЛ ТОХИРУУЛАХ ДЭЛГЭЦ
// Хэрэглэгч цикл бүрийн нэр, үргэлжлэх хугацааг оруулна
// Цикл бүр тусдаа хуудас хэлбэрээр харагдана
// ============================================================
import 'package:flutter/material.dart';
import '../models/cycle_config.dart';
import 'breathing_screen.dart';

class CycleSetupScreen extends StatefulWidget {
  final int cycleCount; // Нийт циклийн тоо
  final int finishMinutes; // Нийт дасгалын хугацаа (минутаар)

  const CycleSetupScreen({
    super.key,
    required this.cycleCount,
    required this.finishMinutes,
  });

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen>
    with WidgetsBindingObserver {
  late List<TextEditingController> _nameControllers; // Циклийн нэрүүд
  late List<TextEditingController> _durationControllers; // Циклийн хугацаанууд
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Цикл бүрийн нэр, хугацааг анхны утгаар тохируулах
    _nameControllers = List.generate(
      widget.cycleCount,
      (i) => TextEditingController(text: 'Цикл ${i + 1}'),
    );
    _durationControllers = List.generate(
      widget.cycleCount,
      (i) => TextEditingController(text: '5'), // Default: 5 секунд
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

  /// "Эхлэх" товч дархад ажиллана - бүх циклийг шалгаад дасгал эхлүүлнэ
  void _onStart() {
    final cycles = <CycleConfig>[];

    for (int i = 0; i < widget.cycleCount; i++) {
      final name = _nameControllers[i].text.trim();
      final duration = int.tryParse(_durationControllers[i].text) ?? 5;

      // Шалгалт
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

    // Дасгалын дэлгэц рүү шилжих
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
          // Хуудас заагч цэгүүд
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

          // Циклийн картууд (хуудаслалттай)
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

          // Удирдлагын товчнууд
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
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  /// Циклийн карт (нэр, хугацаа оруулах)
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
              // Циклийн дугаар (тойрог дотор)
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
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

              // Циклийн нэр
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

              // Үргэлжлэх хугацаа
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
                  _iconButton(
                    Icons.remove,
                    const Color(0xFFef4444),
                    const Color(0xFFfee2e2),
                    onPressed: () {
                      final v = int.tryParse(
                              _durationControllers[index].text) ??
                          5;
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _iconButton(
                    Icons.add,
                    const Color(0xFF22c55e),
                    const Color(0xFFdcfce7),
                    onPressed: () {
                      final v = int.tryParse(
                              _durationControllers[index].text) ??
                          5;
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

  /// Товчлуур
  Widget _iconButton(
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
