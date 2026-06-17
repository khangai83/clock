import 'package:flutter_test/flutter_test.dart';

import 'package:breathing_app/main.dart';

void main() {
  testWidgets('Breathing app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BreathingApp());
    expect(find.text('🌬️ Амьсгалын дасгал'), findsOneWidget);
  });
}
