import 'package:flutter_test/flutter_test.dart';

import 'package:barista_brew/main.dart';

void main() {
  testWidgets('App builds and shows calculator', (WidgetTester tester) async {
    await tester.pumpWidget(const BaristaBrewApp());
    await tester.pump();

    expect(find.text('Gramaj Hesaplayıcı'), findsOneWidget);
    expect(find.text('Hesap'), findsOneWidget);
    expect(find.text('Yöntemler'), findsOneWidget);
  });
}
