import 'package:barista_brew/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds, navigates between tabs, and supports theme toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BaristaBrewApp());
    await tester.pumpAndSettle();

    // Verify calculator screen is shown first
    expect(find.text('Gramaj Hesaplayıcı'), findsOneWidget);
    expect(find.text('Hesap'), findsOneWidget);
    expect(find.text('Yöntemler'), findsOneWidget);
    expect(find.text('Reçeteler'), findsOneWidget);
    expect(find.text('Zamanlayıcı'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);

    // Switch to Yöntemler tab
    await tester.tap(find.text('Yöntemler'));
    await tester.pumpAndSettle();
    expect(find.text('Demleme Yöntemleri'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('V60 (Pour Over)'), findsOneWidget);

    // Switch to Reçeteler tab
    await tester.tap(find.text('Reçeteler'));
    await tester.pumpAndSettle();
    expect(find.text('Reçetelerim'), findsOneWidget);
    expect(find.text('Reçeten yok'), findsOneWidget);

    // Switch to Zamanlayıcı tab
    await tester.tap(find.text('Zamanlayıcı'));
    await tester.pumpAndSettle();
    expect(find.text('Demleme Zamanlayıcı'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Switch to Günlük tab
    await tester.tap(find.text('Günlük'));
    await tester.pumpAndSettle();
    expect(find.text('Demleme Günlüğü'), findsOneWidget);
    expect(find.text('Henüz kayıt yok'), findsOneWidget);

    // Test Theme toggle button in header
    final themeToggleBtn = find.byTooltip('Tema Değiştir (Açık/Koyu/Sistem)');
    expect(themeToggleBtn, findsWidgets);
    await tester.tap(themeToggleBtn.first);
    await tester.pumpAndSettle();
  });

  testWidgets('Method details can launch timer directly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BaristaBrewApp());
    await tester.pumpAndSettle();

    // Open Yöntemler tab
    await tester.tap(find.text('Yöntemler'));
    await tester.pumpAndSettle();

    // Tap on Chemex card
    await tester.tap(find.text('Chemex'));
    await tester.pumpAndSettle();

    // Verify Chemex details page
    expect(find.text('Zamanlayıcıyı Başlat'), findsOneWidget);
    expect(find.text('Hesapla'), findsOneWidget);

    // Tap Zamanlayıcıyı Başlat
    await tester.tap(find.text('Zamanlayıcıyı Başlat'));
    await tester.pumpAndSettle();

    // Verify it automatically landed on Timer screen with Chemex selected
    expect(find.text('Demleme Zamanlayıcı'), findsOneWidget);
    expect(find.text('Chemex'), findsWidgets);
  });
}
