import 'package:flutter_test/flutter_test.dart';
import 'package:sc_synthesis/app.dart';

void main() {
  testWidgets('App renders with default synthwave theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ScSynthesisApp());
    // The UI has continuously running animations (loading indicators while
    // the reference data loads), so pumpAndSettle would never settle.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // App should show the fleet tab by default
    expect(find.text('My Fleet'), findsOneWidget);
    expect(find.text('SC:Synthesis'), findsWidgets);
  });
}
