import 'package:flutter_test/flutter_test.dart';

import 'package:ebus/main.dart';

void main() {
  testWidgets('App shows driver login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EBusApp());

    expect(find.text('Driver Login'), findsOneWidget);
  });
}
