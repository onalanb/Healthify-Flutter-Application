// Baran Onalan
// January 6th, 2024

// Importing the necessary packages for the project.
import 'package:flutter/material.dart';

import 'emotion.dart';
import 'diet.dart';
import 'workout.dart';

void main() {
  runApp(HealthifyApp());
}

// Applications main widget, helps set the theme and home page.
class HealthifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xDED04646), // Background color for app bar.
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,  // Background color for the app.
        ),
      ),
      home: HomePage(),
    );
  }
}

// Main Home page widget containing the page view style.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthify'), // App title.
      ),
      body: WidgetPageView(), // This is the page view to show the different recorders.
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