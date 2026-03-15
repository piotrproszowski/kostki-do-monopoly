import 'package:flutter_test/flutter_test.dart';

import 'package:kostki_monopoly/main.dart';

void main() {
  testWidgets('App smoke test renders dice screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('WYNIK'), findsOneWidget);
    expect(find.text('RZUĆ'), findsOneWidget);
    expect(find.text('HISTORIA'), findsOneWidget);
    expect(find.text('2 kości'), findsOneWidget);
  });
}
