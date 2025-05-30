import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:btc_price/main.dart';

void main() {
  testWidgets('BTCApp renders loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(const BTCApp());

    // Expect CircularProgressIndicator to show while loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // You can also test for expected text or app bar
    expect(find.text('Bitcoin Price Tracker'), findsOneWidget);
  });
}
