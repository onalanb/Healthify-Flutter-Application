import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'recording.dart';

// Workout Recorder Widget
// Allows the user to select a workout from 12 different options and for how long they did it.
// Keeps track of their input and the time, logs their input.
class WorkoutRecorder extends StatefulWidget {
  final List<Map<String, dynamic>> workoutLogs;

  const WorkoutRecorder({required this.workoutLogs, Key? key}) : super(key: key);

  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

// Stateful widget to record workout logs.
class _WorkoutRecorderState extends State<WorkoutRecorder> {
  TextEditingController durationController = TextEditingController();
  late List<Map<String, dynamic>> workoutLogs;

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

    // Record the emotion using the provider
    recordingProvider.record('Workout');

    String duration = durationController.text;

    if (duration.isNotEmpty) {
      setState(() {
        workoutLogs.insert(0, {
          'exercise': selectedExercise,
          'duration': duration,
          'timestamp': DateTime.now(),
        });
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
                  title: Text('${workoutLogs[index]['exercise']}'), // Displays logged exercise.
                  subtitle: Text(
                    // Displays duration and timestamp of the logged workout entry.
                    'Duration: ${workoutLogs[index]['duration']} mins \nLogged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(workoutLogs[index]['timestamp'])}',
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