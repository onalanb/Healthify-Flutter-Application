import 'package:flutter/material.dart';
import 'package:flutter_app/diet.dart';
import 'package:flutter_app/recording.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting

void main() {
  testWidgets('Diet Recorder Widget Test', (WidgetTester tester) async {
    // Mock RecordingProvider
    final recordingProvider = RecordingProvider();
    recordingProvider.record('Diet');

    // Build our app and trigger a frame.
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: recordingProvider),
              ],
              child: Scaffold(
                body: DietRecorder(dietLogs: []),
              ),
            ),
          ),
        );

    // Verify that the UI elements are displayed.
    expect(find.text('What did you eat today?'), findsOneWidget);
    expect(find.text('Enter food'), findsOneWidget);
    expect(find.text('Enter quantity'), findsOneWidget);

    // Enter some diet information and log it.
    await tester.enterText(find.byType(TextField).at(0), 'Pizza'); // Assumes the first TextField is for food
    await tester.enterText(find.byType(TextField).at(1), '2000');  // Assumes the second TextField is for quantity
    await tester.tap(find.text('Calories'));
    await tester.pump();
    await tester.tap(find.text('Grams'));
    await tester.pump();
    await tester.tap(find.text('Log Diet'), warnIfMissed: false);   // Tap "Log Diet" with a small delay
    await tester.pump();

    // Verify that the logged diet is displayed.
    expect(find.text('Logged Diets:'), findsOneWidget);
    expect(find.text('Pizza (2000 Grams)'), findsOneWidget);
    DateTime dateTimeNow = DateTime.now();
    expect(find.text('Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(dateTimeNow)}'), findsOneWidget);

    // Verify that the drop down is displayed.
    expect(find.text('Pizza'), findsOneWidget);
  });
}
