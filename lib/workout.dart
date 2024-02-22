import 'package:flutter/material.dart';
import 'package:flutter_app/style_switching_button.dart';
import 'package:flutter_app/style_switching_dropdown.dart';
import 'package:flutter_app/style_switching_text_field.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter/cupertino.dart';
import 'recording.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'style_switching_list_view.dart';

// Workout Recorder Widget
// Allows the user to select a workout from 12 different options and for how long they did it.
// Keeps track of their input and the time, logs their input.
class WorkoutRecorder extends StatefulWidget {
  final List<Map<dynamic, dynamic>> workoutLogs;

  WorkoutRecorder({required this.workoutLogs, Key? key}) : super(key: key);

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

/******************************************************************************/

// Stateful widget to record workout logs.
class _WorkoutRecorderState extends State<WorkoutRecorder> {
  TextEditingController durationController = TextEditingController();
  late List<Map<dynamic, dynamic>> workoutLogs;

  // The default exercise when the user opens the app.
  String? selectedExercise;

  @override
  void initState() {
    super.initState();
    workoutLogs = widget.workoutLogs;
  }

  // Logs the workout information with a timestamp.
  void logWorkout() {
    // Get an instance of RecordingProvider
    final recordingProvider = Provider.of<RecordingProvider>(context, listen: false);

    String duration = durationController.text;

    var now = DateTime.now();
    var loggedWorkout = {
      'exercise': selectedExercise ?? AppLocalizations.of(context)!.dancing,
      'duration': duration,
      'timestamp': now,
    };

    if (duration.isNotEmpty) {
      // Record the workout using the provider
      recordingProvider.record('Workout');

      // Add the workout to hive database
      var workoutBox = Hive.box<Map<dynamic, dynamic>>('WorkoutBox');
      workoutBox.put(now.millisecondsSinceEpoch.toString(), loggedWorkout);

      // Allows us to set the state for the local change so that it is re-rendered
      setState(() {
        workoutLogs.insert(0, loggedWorkout);
      });

      // Clear the text field after logging
      durationController.clear();
    }
  }

  void onDelete(int index) {
    // Delete the workout from hive database
    // Add the workout to hive database
    var workoutBox = Hive.box<Map<dynamic, dynamic>>('WorkoutBox');
    var workoutKey = (workoutLogs[index]['timestamp'] as DateTime).millisecondsSinceEpoch.toString();
    workoutBox.delete(workoutKey);
    print('Deleting key $workoutKey');
    print('Remaining keys ${workoutBox.keys}');
    print('Remaining values ${workoutBox.values}');
    setState(() {
      workoutLogs.removeAt(index);
    });
  }

  String getTitle(int index) {
    return '${workoutLogs[index]['exercise']} ${AppLocalizations.of(context)!.loggedWorkout(workoutLogs[index]['duration'])}';
  }

  String getSubtitle(int index) {
    return AppLocalizations.of(context)!.loggedAt(workoutLogs[index]['timestamp'], workoutLogs[index]['timestamp']);
  }

  void exerciseSelected(String? newValue) {
    setState(() {
      selectedExercise = newValue!; // Updates the selected exercise when changed.
    });
  }

  // Widget UI for recording the user's workout information.
  @override
  Widget build(BuildContext context) {
    // List of exercises the users get to pick from.
    List<String> exercises = [
    AppLocalizations.of(context)!.dancing, AppLocalizations.of(context)!.cycling, AppLocalizations.of(context)!.running, AppLocalizations.of(context)!.swimming,
      AppLocalizations.of(context)!.weightlifting, AppLocalizations.of(context)!.yoga, AppLocalizations.of(context)!.martialArts, AppLocalizations.of(context)!.rowing,
      AppLocalizations.of(context)!.climbing, AppLocalizations.of(context)!.jumpRope, AppLocalizations.of(context)!.parkour, AppLocalizations.of(context)!.stabilityTraining
    ];

    return Padding(
      padding: EdgeInsets.all(20), // Padding around the widget.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left side) of the column.
        children: [
          Text(
            AppLocalizations.of(context)!.workoutQuestion, // Title asking about the user's workout.
            style: TextStyle(fontSize: 18), // Style for the title.
          ),
          StyleSwitchingDropDown(
              dropDownMenuOptionList: exercises,
              getSelectedValue: () { return selectedExercise ?? AppLocalizations.of(context)!.dancing; },
              onSelect: exerciseSelected),
          const SizedBox(height: 20),             // Spacing between the exercise selection and duration input.
          Text(
            AppLocalizations.of(context)!.duration, // Label for duration input.
            style: TextStyle(fontSize: 18), // Style for the label.
          ),
          StyleSwitchingTextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              getHintText: () { return AppLocalizations.of(context)!.hintDuration; }),
          const SizedBox(height: 20),         // Spacing between duration input and log workout button.
          StyleSwitchingButton(interaction: logWorkout, getButtonText: () { return AppLocalizations.of(context)!.logWorkout; }),
          const SizedBox(height: 20), // Spacing between log workout button and logged workout list.
          Text(
            AppLocalizations.of(context)!.loggedWorkouts,                 // Title for the list of logged workouts.
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for the title.
          ),
          Expanded(
            child: StyleSwitchingListView(logSize: workoutLogs.length ,getTitle: getTitle, getSubtitle: getSubtitle, onDelete: onDelete, onUpdate: null),
          ),
        ],
      ),
    );
  }
}