// ============================================================
// BREATHING APP - Үндсэн апп widget
// MaterialApp-ийн тохиргоо (theme, dark mode, гарчиг)
// ============================================================
import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

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
