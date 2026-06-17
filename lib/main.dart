// ============================================================
// ОРЦ ЦЭГ - Апп эхлэх цэг
// Эндээс апп ажиллаж эхэлнэ
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // Flutter engine эхлүүлэх
  WidgetsFlutterBinding.ensureInitialized();

  // Зөвхөн босоо чиглэлд харуулах
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Аппыг ажиллуулах
  runApp(const BreathingApp());
}
