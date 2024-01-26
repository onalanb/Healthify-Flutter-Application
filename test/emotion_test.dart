import 'package:flutter/material.dart';
import 'package:flutter_app/emotion.dart';
import 'package:flutter_app/recording.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting


void main() {
  testWidgets('Emotion Recorder Widget Test', (WidgetTester tester) async {
    // Mock RecordingProvider
    final recordingProvider = RecordingProvider();
    recordingProvider.record('Emotion');

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: recordingProvider),
          ],
          child: Scaffold( // Scaffold introduces a Material ancestor
            body: EmotionRecorder(emotionLogs: []),
          ),
        ),
      ),
    );

    // Verify that the emoji list is displayed.
    expect(find.text('😊'), findsOneWidget);
    expect(find.text('😔'), findsOneWidget);

    // Tap on an emoji and verify it's logged.
    await tester.tap(find.text('😊'));
    await tester.pump();

    // Verify that the logged emotion is displayed.
    expect(find.text('Logged Emotions:'), findsOneWidget);
    expect(find.text('😊'), findsNWidgets(2));
    DateTime dateTimeNow = DateTime.now();
    expect(find.text('Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(dateTimeNow)}'), findsOneWidget);
  });
}
