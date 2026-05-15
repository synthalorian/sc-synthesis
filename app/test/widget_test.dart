import 'package:flutter_test/flutter_test.dart';
import 'package:sc_synthesis/app.dart';

void main() {
  testWidgets('App renders with default synthwave theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ScSynthesisApp());
    await tester.pumpAndSettle();

    // App should show the fleet tab by default
    expect(find.text('My Fleet'), findsOneWidget);
    expect(find.text('SC:Synthesis'), findsWidgets);
  });
}
