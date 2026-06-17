// ============================================================
// ЭХЛЭЛ ДЭЛГЭЦ - Тохиргоо
// Эндээс хэрэглэгч циклийн тоо болон нийт хугацааг оруулна
// ============================================================
import 'package:flutter/material.dart';
import 'cycle_setup_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  // Циклийн тоо (default: 3)
  final _cycleCountController = TextEditingController(text: '3');
  // Дуусах хугацаа минутаар (default: 5)
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

  /// "Циклүүдээ тохируулах" товч дархад ажиллана
  void _onNext() {
    final cycles = int.tryParse(_cycleCountController.text) ?? 3;
    final minutes = int.tryParse(_finishTimeController.text) ?? 5;

    // Шалгалт
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

    // Дараагийн хуудас руу шилжих
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
              // Гарчиг
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

              // --- Циклийн тоо оруулах хэсэг ---
              _buildInputCard(
                context,
                icon: '🔄',
                title: 'Циклийн тоо (Cycle)',
                subtitle: 'Хэдэн циклтэй байх вэ?',
                controller: _cycleCountController,
                onMinus: () {
                  final v = int.tryParse(_cycleCountController.text) ?? 3;
                  if (v > 1) _cycleCountController.text = '${v - 1}';
                },
                onPlus: () {
                  final v = int.tryParse(_cycleCountController.text) ?? 3;
                  if (v < 50) _cycleCountController.text = '${v + 1}';
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // --- Дуусах хугацаа оруулах хэсэг ---
              _buildInputCard(
                context,
                icon: '⏱️',
                title: 'Дуусах хугацаа (Finish Time)',
                subtitle: 'Нийт хэдэн минут үргэлжлэх вэ?',
                controller: _finishTimeController,
                onMinus: () {
                  final v = int.tryParse(_finishTimeController.text) ?? 5;
                  if (v > 1) _finishTimeController.text = '${v - 1}';
                },
                onPlus: () {
                  final v = int.tryParse(_finishTimeController.text) ?? 5;
                  if (v < 120) _finishTimeController.text = '${v + 1}';
                },
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // --- Дараагийн товч ---
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Тоо оруулах карт (циклийн тоо / дуусах хугацаа)
  Widget _buildInputCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required bool isDark,
  }) {
    return Container(
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
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
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
              // Хасах товч
              _iconButton(
                Icons.remove,
                const Color(0xFFef4444),
                const Color(0xFFfee2e2),
                onPressed: onMinus,
              ),
              const SizedBox(width: 12),
              // Тоо оруулах талбар
              Expanded(
                child: TextField(
                  controller: controller,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Нэмэх товч
              _iconButton(
                Icons.add,
                const Color(0xFF22c55e),
                const Color(0xFFdcfce7),
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Дугуй товчлуур
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
