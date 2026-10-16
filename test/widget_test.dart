import 'package:brew_app/main.dart';
import 'package:brew_app/screens/grind_guide_screen.dart';
import 'package:brew_app/screens/startup_screen.dart';
import 'package:brew_app/widgets/grinder_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Startup screen animates the branded loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: StartupScreen()));

    expect(find.text('Brew App'), findsOneWidget);
    expect(find.text('Getting your coffee ready'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('App builds, navigates between tabs, and supports theme toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    expect(find.text('Coffee Ratio Calculator'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Methods'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(
      tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.byType(Text),
            ),
          )
          .map((text) => text.data),
      ['Calculator', 'Methods', 'Timer', 'Recipes', 'Journal'],
    );

    await tester.tap(find.text('Methods'));
    await tester.pumpAndSettle();
    expect(find.text('Brewing Methods'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('V60 (Pour Over)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Kalita');
    await tester.pumpAndSettle();
    expect(find.text('Kalita Wave'), findsOneWidget);

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    expect(find.text('My recipes'), findsOneWidget);
    expect(find.text('No recipes yet'), findsOneWidget);

    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();
    expect(find.text('Brew Timer'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Brew Journal'), findsOneWidget);
    expect(find.text('No entries yet'), findsOneWidget);

    final themeToggleBtn = find.byTooltip('Change theme (light/dark/system)');
    expect(themeToggleBtn, findsWidgets);
    await tester.tap(themeToggleBtn.first);
    await tester.pumpAndSettle();
  });

  testWidgets('App interface stays English on a Turkish device', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    expect(find.text('Coffee Ratio Calculator'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Hesap'), findsNothing);
  });

  testWidgets('Method details can launch timer directly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Methods'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Chemex'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Chemex'));
    await tester.pumpAndSettle();

    expect(find.text('Start timer'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);

    await tester.tap(find.text('Start timer'));
    await tester.pumpAndSettle();

    expect(find.text('Brew Timer'), findsOneWidget);
    expect(find.text('Chemex'), findsWidgets);
  });

  testWidgets('Help and legal information are reachable from settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings and backup').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Help and legal information'));
    await tester.pumpAndSettle();

    expect(find.text('Frequently asked questions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('How can I personalize a recipe?'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('How can I personalize a recipe?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Privacy notice'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Privacy notice'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Terms of use'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Terms of use'), findsOneWidget);
  });

  testWidgets('Grinder calibration is reachable from settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings and backup').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grinder calibration').last);
    await tester.pumpAndSettle();

    expect(find.text('Tested settings by method'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Grinder brand / model'),
      findsOneWidget,
    );
  });

  testWidgets('Grinder dial adjusts numerical settings with buttons and drag', (
    WidgetTester tester,
  ) async {
    var value = 18.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => GrinderDial(
              value: value,
              unit: 'clicks',
              step: 0.5,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    expect(find.text('18'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase setting'));
    await tester.pumpAndSettle();
    expect(find.text('18.5'), findsOneWidget);

    await tester.drag(find.byType(GrinderDial), const Offset(80, 0));
    await tester.pumpAndSettle();

    expect(value, greaterThan(18.5));
  });

  testWidgets('Main calculator has a grinder calibration shortcut', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    expect(find.text('Grinder calibration'), findsOneWidget);
    expect(find.text('Save settings for espresso and other methods'), findsOneWidget);

    await tester.tap(find.text('Grinder calibration'));
    await tester.pumpAndSettle();
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Tested settings by method'), findsOneWidget);
  });

  testWidgets('Popular brew ratios select matching measured profiles', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batch Brew (1:16)'));
    await tester.pumpAndSettle();

    expect(find.text('30 g coffee'), findsOneWidget);
    expect(find.text('480 ml'), findsOneWidget);
    expect(find.text('93°C'), findsOneWidget);
  });

  testWidgets('Coffee and grind guides open from the calculator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coffee guide'));
    await tester.pumpAndSettle();
    expect(find.text('Know your coffee'), findsOneWidget);
    expect(find.text('Capsule coffee'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Whole-bean coffee'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Whole-bean coffee'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pre-ground coffee'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Pre-ground coffee'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Coffee Ratio Calculator'), findsOneWidget);
  });

  testWidgets('Grind guide animates method-specific particle settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GrindGuideScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Grind controls the flow'), findsOneWidget);
    expect(find.text('Grind particle visualization'), findsOneWidget);
    expect(find.text('Choose a brewing method'), findsOneWidget);
  });

  testWidgets('New recipes default to a matching filter-coffee ratio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BrewApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recipes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.textContaining('Water:'), findsOneWidget);
    expect(find.textContaining('Espresso yield:'), findsNothing);
  });
}
