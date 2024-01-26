import 'package:flutter/material.dart';
import 'package:flutter_app/recording.dart';
import 'package:flutter_app/workout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting

void main() {
  testWidgets('Workout Recorder Widget Test', (WidgetTester tester) async {
    // Mock RecordingProvider
    final recordingProvider = RecordingProvider();
    recordingProvider.record('Workout');

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: recordingProvider),
          ],
          child: Scaffold(
            body: WorkoutRecorder(workoutLogs: []),
          ),
        ),
      ),
    );

    // Verify that the UI elements are displayed.
    expect(find.text('What was your workout today?'), findsOneWidget);
    expect(find.text('Duration (minutes):'), findsOneWidget);
    expect(find.text('Log Workout'), findsOneWidget);

    // Select a workout and log it.
    await tester.tap(find.text('Dancing'));
    await tester.pump();
    await tester.tap(find.text('Yoga'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '30');
    await tester.tap(find.text('Log Workout'));
    await tester.pump();

    // Verify that the logged workout is displayed.
    expect(find.text('Logged Workouts:'), findsOneWidget);
    expect(find.text('Yoga (30 mins)'), findsOneWidget);
    DateTime dateTimeNow = DateTime.now();
    expect(find.text('Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(dateTimeNow)}'), findsOneWidget);
  });
}
