import 'package:flutter_test/flutter_test.dart';

import 'package:kainph/main.dart';

void main() {
  testWidgets('KainPH app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KainPHApp());

    expect(find.text('KainPH'), findsOneWidget);
    expect(find.text('Good evening! 👋'), findsOneWidget);
  });
}
