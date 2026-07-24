import 'package:flutter_test/flutter_test.dart';

import 'package:souki_app/main.dart';

void main() {
  testWidgets('SoukiApp lance sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const SoukiApp());
    expect(find.byType(SoukiApp), findsOneWidget);
  });
}
