import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:hive/hive.dart';
import 'recording.dart';

// Workout Recorder Widget
// Allows the user to select a workout from 12 different options and for how long they did it.
// Keeps track of their input and the time, logs their input.
class WorkoutRecorder extends StatefulWidget {
  final List<Map<dynamic, dynamic>> workoutLogs;

  WorkoutRecorder({required this.workoutLogs, Key? key}) : super(key: key);

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

// Stateful widget to record workout logs.
class _WorkoutRecorderState extends State<WorkoutRecorder> {
  TextEditingController durationController = TextEditingController();
  late List<Map<dynamic, dynamic>> workoutLogs;

  // List of exercises the users get to pick from.
  final List<String> exercises = [
    'Dancing', 'Cycling', 'Running', 'Swimming',
    'Weightlifting', 'Yoga', 'Martial Arts', 'Rowing',
    'Climbing' , 'Jump Rope', 'Parkour', 'Stability Training'
  ];

  // The default exercise when the user opens the app.
  String selectedExercise = 'Dancing';

  @override
  void initState() {
    super.initState();
    workoutLogs = widget.workoutLogs;
  }

  // Logs the workout information with a timestamp.
  void logWorkout() {
    // Get an instance of RecordingProvider
    final recordingProvider = Provider.of<RecordingProvider>(context, listen: false);

    // Record the workout using the provider
    recordingProvider.record('Workout');

    String duration = durationController.text;

    var now = DateTime.now();
    var loggedWorkout = {
      'exercise': selectedExercise,
      'duration': duration,
      'timestamp': now,
    };

    // Add the workout to hive database
    var workoutBox = Hive.box<Map<dynamic, dynamic>>('WorkoutBox');
    workoutBox.put(now.millisecondsSinceEpoch.toString(), loggedWorkout);

    if (duration.isNotEmpty) {
      setState(() {
        workoutLogs.insert(0, loggedWorkout);
      });

      // Clear the text field after logging
      durationController.clear();
    }
  }

  // Widget UI for recording the user's workout information.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20), // Padding around the widget.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left side) of the column.
        children: [
          const Text(
            'What was your workout today?', // Title asking about the user's workout.
            style: TextStyle(fontSize: 18), // Style for the title.
          ),
          DropdownButton<String>(
            value: selectedExercise,  // Currently selected exercise.
            onChanged: (String? newValue) {
              setState(() {
                selectedExercise = newValue!; // Updates the selected exercise when changed.
              });
            },
            items: exercises.map((String exercise) {
              return DropdownMenuItem<String>(
                value: exercise,
                child: Text(exercise),  // Displays the available exercises in the dropdown.
              );
            }).toList(),
          ),
          const SizedBox(height: 20),             // Spacing between the exercise selectio and duration input.
          const Text(
            'Duration (minutes):',          // Label for duration input.
            style: TextStyle(fontSize: 18), // Style for the label.
          ),
          TextField(
            controller: durationController,     // Text field to input the workout duration.
            keyboardType: TextInputType.number, // Keyboard for duration input.
            decoration: const InputDecoration(
              hintText: 'Enter duration',       // Placeholder text for duration text field.
            ),
          ),
          const SizedBox(height: 20),         // Spacing between duration input and log workout button.
          ElevatedButton(
            onPressed: logWorkout,      // Function to log the workout entry.
            child: const Text('Log Workout'), // Text for the button.
          ),
          const SizedBox(height: 20), // Spacing between log workout button and logged workout list.
          const Text(
            'Logged Workouts:', // Title for the list of logged workouts.
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for the title.
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workoutLogs.length,  // Total number of logged workouts.
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${workoutLogs[index]['exercise']} (${workoutLogs[index]['duration']} mins)'), // Displays logged exercise.
                  subtitle: Text(
                    // Displays duration and timestamp of the logged workout entry.
                    'Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(workoutLogs[index]['timestamp'])}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Implement your edit logic here
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
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
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}