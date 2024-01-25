// Baran Onalan
// January 6th, 2024

// Importing the necessary packages for the project.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'emotion.dart';
import 'diet.dart';
import 'workout.dart';
import 'recording.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecordingProvider()),
      ],
      child: HealthifyApp(),
    ),
  );
}

// Applications main widget, helps set the theme and home page.
class HealthifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xDED04646), // Background color for app bar.
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,  // Background color for the app.
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Healthify'), // Set the title of the app bar.
        ),
        body: HomePage(), // Set the body of the app.
      ),
    );
  }
}

// Main Home page widget containing the page view style.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isInitialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPersistentBottomSheet(context);
    });
  }

  void _showPersistentBottomSheet(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<RecordingProvider>(
          builder: (context, recordingProvider, child) {
            // Check if the initial data has been loaded
            if (!isInitialDataLoaded) {
              isInitialDataLoaded = true;
              return Container(
                padding: EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last Log: \nLog Time: \nDedication Level: ',
                      style: TextStyle(fontSize: 14),
                    ),
                    // Add any additional content or buttons if needed
                  ],
                ),
              );
            } else {
              // Display data after the first log
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last Log: ${recordingProvider.lastRecordingType}\nLog Time: ${recordingProvider.formattedLastRecordingTime}\nDedication Level: ${recordingProvider.recordingPoints}',
                      style: TextStyle(fontSize: 14),
                    ),
                    // Add any additional content or buttons if needed
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WidgetPageView(),
    );
  }
}

// Page view widget displaying different recorders.
class WidgetPageView extends StatelessWidget {
  List<Map<String, dynamic>> workoutLogs = [];
  List<Map<String, dynamic>> dietLogs = [];
  List<Map<String, dynamic>> emotionLogs = [];

  final Key emotionRecorderKey = UniqueKey();
  final Key dietRecorderKey = UniqueKey();
  final Key workoutRecorderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        EmotionRecorder(emotionLogs: emotionLogs, key: emotionRecorderKey), // First page - Emotion Recorder.
        DietRecorder(dietLogs: dietLogs, key: dietRecorderKey), // Second page - Diet Recorder.
        WorkoutRecorder(workoutLogs: workoutLogs, key: workoutRecorderKey), // Third page - Workout Recorder.
      ],
    );
  }
}