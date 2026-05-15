import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_scanner/main.dart';

void main() {
  testWidgets('Home page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OCRScannerApp());

    // Verify that the home page title is present.
    expect(find.text('Smart Scanner'), findsOneWidget);
    
    // Verify that the description text is present.
    expect(
      find.text('Extract information instantly from cards and documents.'), 
      findsOneWidget
    );

    // Verify that both scanner cards are present.
    expect(find.text('Card Scanner'), findsOneWidget);
    expect(find.text('Passbook Scanner'), findsOneWidget);
  });
}
