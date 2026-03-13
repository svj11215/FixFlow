import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow/app.dart';

void main() {
  testWidgets('FixFlow app smoke test', (WidgetTester tester) async {
    // Smoke test - just verify the app widget exists
    expect(const FixFlowApp(), isNotNull);
  });
}
