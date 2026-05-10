import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pbl_apotik_kelompok_4/main.dart';

void main() {
  testWidgets('App renders MaterialApp with correct title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Apotek Kelompok 4');

    // OpeningPage memulai timer 3 detik untuk navigasi — selesaikan agar test bersih.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
