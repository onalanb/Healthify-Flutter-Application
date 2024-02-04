// Baran Onalan
// January 6th, 2024

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'emotion.dart';
import 'diet.dart';
import 'workout.dart';
import 'recording.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Delete the hive boxes to start fresh
  // await Hive.deleteBoxFromDisk('EmotionBox');

  await Hive.openBox<Map<dynamic, dynamic>>('EmotionBox');
  await Hive.openBox<Map<dynamic, dynamic>>('DietBox');
  await Hive.openBox<Map<dynamic, dynamic>>('WorkoutBox');
  await Hive.openBox<String>('FoodDropdownBox');

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
          primarySwatch: Colors.deepOrange,  // Background color for the app.
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
  final Key emotionRecorderKey = UniqueKey();
  final Key dietRecorderKey = UniqueKey();
  final Key workoutRecorderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    var emotionBox = Hive.box<Map<dynamic, dynamic>>('EmotionBox');
    List<Map<dynamic, dynamic>> allEmotions = emotionBox.values.toList();
    print('allEmotions: $allEmotions');
    List<Map<dynamic, dynamic>> emotionLogs = allEmotions.reversed.toList();
    print('emotionLogs: $emotionLogs');

    var dietBox = Hive.box<Map<dynamic, dynamic>>('DietBox');
    List<Map<dynamic, dynamic>> allDiets = dietBox.values.toList();
    print('allDiets: $allDiets');
    List<Map<dynamic, dynamic>> dietLogs = allDiets.reversed.toList();
    print('dietLogs: $dietLogs');

    var foodDropdownBox = Hive.box<String>('FoodDropdownBox');
    Set<String> foodDropdown = foodDropdownBox.values.toSet();
    print('foodDropdown: $foodDropdown');

    var workoutBox = Hive.box<Map<dynamic, dynamic>>('WorkoutBox');
    List<Map<dynamic, dynamic>> allWorkouts = workoutBox.values.toList();
    print('allWorkouts: $allWorkouts');
    List<Map<dynamic, dynamic>> workoutLogs = allWorkouts.reversed.toList();
    print('workoutLogs: $workoutLogs');

    return PageView(
      children: [
        EmotionRecorder(emotionLogs: emotionLogs, key: emotionRecorderKey), // First page - Emotion Recorder.
        DietRecorder(dietLogs: dietLogs, foodDropdown: foodDropdown, key: dietRecorderKey), // Second page - Diet Recorder.
        WorkoutRecorder(workoutLogs: workoutLogs, key: workoutRecorderKey), // Third page - Workout Recorder.
      ],
    );
  }
}