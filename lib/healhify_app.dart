import 'package:flutter/material.dart';
import 'package:flutter_app/style_switching_button.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'emotion.dart';
import 'diet.dart';
import 'workout.dart';
import 'recording.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthifyApp extends StatelessWidget {
  final Key emotionRecorderKey = UniqueKey();
  final Key dietRecorderKey = UniqueKey();
  final Key workoutRecorderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {

    User? userCredential = FirebaseAuth.instance.currentUser;
    print(userCredential);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPersistentBottomSheet(context);
    });

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

    // This repeats for every page,
    // so defining once here to use in routes below multiple times.
    var healthifyAppBar = AppBar(
      title: const Text('Healthify'),
    );

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xDED04646), // Background color for app bar.
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange,  // Background color for the app.
        ),
      ),
      initialRoute: '/emotion',
      routes: {
        '/emotion': (context) => Scaffold(
          appBar: healthifyAppBar,
          body: Column(
            children: [
              SizedBox(height: 5),
              createNavigationButtons(context),
              SizedBox(height: 5),
              Expanded(
                child: EmotionRecorder(emotionLogs: emotionLogs, key: emotionRecorderKey),
              ),
            ],
          ),
        ),
        '/diet': (context) => Scaffold(
          appBar: healthifyAppBar,
          body: Column(
            children: [
              SizedBox(height: 5),
              createNavigationButtons(context),
              SizedBox(height: 5),
              Expanded(
                child: DietRecorder(dietLogs: dietLogs, foodDropdown: foodDropdown, key: dietRecorderKey),
              ),
            ],
          ),
        ),
        '/workout': (context) => Scaffold(
          appBar: healthifyAppBar,
          body: Column(
            children: [
              SizedBox(height: 5),
              createNavigationButtons(context),
              SizedBox(height: 5),
              Expanded(
                child: WorkoutRecorder(workoutLogs: workoutLogs, key: workoutRecorderKey),
              ),
            ],
          ),
        ),
      },
    );
  }

  // Builds the persistent bottom sheet.
  void _showPersistentBottomSheet(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<RecordingProvider>(
          builder: (context, recordingProvider, child) {
            // Check if the initial data has been loaded
            var sheetText = recordingProvider.lastRecordingType == '' ?
            AppLocalizations.of(context)!.persistentSheetEmptyText :
            AppLocalizations.of(context)!.persistentSheetText(recordingProvider.lastRecordingType, recordingProvider.lastRecordingTime, recordingProvider.lastRecordingTime, recordingProvider.recordingPoints);

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sheetText, style: TextStyle(fontSize: 14))
                ],
              ),
            );
          },
        );
      },
    );
  }

  // We create navigation buttons for every page,
  // so defining once here to use in routes above multiple times
  Widget createNavigationButtons(BuildContext context) {
    Widget navigationButtons = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 5),
          Expanded(
              child: StyleSwitchingButton(
                  interaction: () { Navigator.pushNamed(context, '/emotion'); },
                  getButtonText: () { return AppLocalizations.of(context)!.logEmotion; })),
          SizedBox(width: 5), // Add spacing between the buttons
          Expanded(
              child: StyleSwitchingButton(
                  interaction: () { Navigator.pushNamed(context, '/diet'); },
                  getButtonText: () { return AppLocalizations.of(context)!.logDiet; })),
          SizedBox(width: 5), // Add spacing between the buttons
          Expanded(
              child: StyleSwitchingButton(
                  interaction: () { Navigator.pushNamed(context, '/workout'); },
                  getButtonText: () { return AppLocalizations.of(context)!.logWorkout; })),
          SizedBox(width: 5),
        ]
    );
    return navigationButtons;
  }
}