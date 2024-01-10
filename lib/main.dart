// Baran Onalan
// January 6th, 2024

// Importing the necessary packages for the project.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting

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
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        EmotionRecorder(), // First page - Emotion Recorder.
        DietRecorder(), // Second page - Diet Recorder.
        WorkoutRecorder(), // Third page - Workout Recorder.
      ],
    );
  }
}

// Emotion Recorder Widget
// Allows user to choose from one of 30 hard coded emojis to express how they currently feel.
// Keeps track of their choice and when the emoji was selected, logs their input.
class EmotionRecorder extends StatefulWidget {
  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

// Stateful widget to record the emotions with emojis.
class _EmotionRecorderState extends State<EmotionRecorder> {
  List<Map<String, dynamic>> emotions = [];

  // Hard-coded list of 30 emojis for the user's selection.
  final List<String> emojiList = [
    "😊", "😔", "😍", "😂", "😭", "😡", "😴", "🥳", "😎", "😇",
    "😐", "😬", "😒", "😳", "🤔", "😕", "😱", "😞", "😤", "🥺",
    "🤗", "😋", "😶", "🤢", "😵", "😈", "🙄", "😬", "😰", "🤩"
  ];

  // Logs the selected emoji from user and creates a timestamp.
  void logEmotion(String selectedEmoji) {
    setState(() {
      emotions.insert(0, {
        'emoji': selectedEmoji,
        'timestamp': DateTime.now(),
      });
    });
  }

  // Widget UI for recording the user's emotions.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What emoji expresses how you feel?', // Title asking the user to select an emoji.
          style: TextStyle(fontSize: 18),       // Style for the title
        ),
        SizedBox(height: 20), // Spacing between the title and emoji list.
        Wrap(
          spacing: 10,    // Horizontal space between emojis.
          runSpacing: 10, // Vertical space between emojis.
          children: emojiList.map((emoji) {
            // Mapping the list of emojis to gesture detector widgets.
            return GestureDetector(
              onTap: () => logEmotion(emoji), // Gesture detection to log selected emoji.
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFA7268)), // Border color around each emoji.
                  borderRadius: BorderRadius.circular(8),       // Rounded corners for the emojis.
                ),
                child: Text(
                  emoji,                          // Display the emoji.
                  style: TextStyle(fontSize: 30), // Size of emoji.
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20), // Spacing between emoji list and logged emotions.
        Text(
          'Logged Emotions:',                                           // Title for logged emotions.
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for title.
        ),
        SizedBox(height: 10), // Spacing between title and logged emotions list.
        Expanded(
          child: ListView.builder(
            itemCount: emotions.length, // Total number of logged emotions.
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(emotions[index]['emoji']),  // Displays the logged emoji.
                subtitle: Text(
                  'Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(emotions[index]['timestamp'])}',  // Displays the timestamp of the logged emotion.
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Diet Recorder Widget
// Allows user to type in what they ate and how much of it they had.
// The amount of food can be input as calories, quantity, or grams.
// Keeps track of how much they ate and when, logs their input.
class DietRecorder extends StatefulWidget {
  @override
  _DietRecorderState createState() => _DietRecorderState();
}

// Stateful widget to record diet logs.
class _DietRecorderState extends State<DietRecorder> {
  TextEditingController foodController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> dietLogs = [];
  String selectedUnit = 'Calories'; // Default unit

  // Log user's diet information with a timestamp.
  void logDiet() {
    String food = foodController.text;
    String quantity = quantityController.text;

    if (food.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        dietLogs.insert(0, {
          'food': food,
          'quantity': quantity,
          'unit': selectedUnit,
          'timestamp': DateTime.now(),
        });
      });

      // Clear the text fields after logging
      foodController.clear();
      quantityController.clear();
    }
  }

  // Widget UI for recording the user's diet information.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),  // Padding around the widget.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left side) of the column.
        children: [
          Text(
            'What did you eat today?',      // Title asking about the user's diet.
            style: TextStyle(fontSize: 18), // Style for the title.
          ),
          TextField(
            controller: foodController,   // Text field for input food.
            decoration: InputDecoration(
              hintText: 'Enter food',     // Placeholder text for food input.
            ),
          ),
          SizedBox(height: 20), // Spacing between food and quantity input.
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quantityController,     // Text field for quantity input.
                  keyboardType: TextInputType.number, // Keyboard for quantity input.
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',       // Placeholder text for quantity input.
                  ),
                ),
              ),
              SizedBox(width: 10),    // Spacing between quantity input and unit selection.
              DropdownButton<String>(
                value: selectedUnit,  // Currently selected unit. (I.E. Calories, Grams, Items)
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue!; // Updates the selected unit when changed.
                  });
                },
                items: ['Calories', 'Grams', 'Items'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),  // Displays available units in the dropdown.
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20),       // Spacing between unit selection and log diet button.
          ElevatedButton(
            onPressed: logDiet,       // Function to log the diet entry.
            child: Text('Log Diet'),  // Text for the button.
          ),
          SizedBox(height: 20), // Spacing between log diet button and logged diet list.
          Text(
            'Logged Diets:',    // Title for the list of logged diets.
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for the title.
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dietLogs.length, // Total number of logged diets.
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${dietLogs[index]['food']}'),  // Displays logged food.
                  subtitle: Text(
                    // Displays quantity, unit, and timestamp of the logged diet entry.
                    'Quantity: ${dietLogs[index]['quantity']} ${dietLogs[index]['unit']} \nLogged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(dietLogs[index]['timestamp'])}',
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

// Workout Recorder Widget
// Allows the user to select a workout from 12 different options and for how long they did it.
// Keeps track of their input and the time, logs their input.
class WorkoutRecorder extends StatefulWidget {
  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

// Stateful widget to record workout logs.
class _WorkoutRecorderState extends State<WorkoutRecorder> {
  TextEditingController durationController = TextEditingController();
  List<Map<String, dynamic>> workoutLogs = [];

  // List of exercises the users get to pick from.
  final List<String> exercises = [
    'Dancing', 'Cycling', 'Running', 'Swimming',
    'Weightlifting', 'Yoga', 'Martial Arts', 'Rowing',
    'Climbing' , 'Jump Rope', 'Parkour', 'Stability Training'
  ];

  // The default exercise when the user opens the app.
  String selectedExercise = 'Dancing';

  // Logs the workout information with a timestamp.
  void logWorkout() {
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
          Text(
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
          SizedBox(height: 20),             // Spacing between the exercise selectio and duration input.
          Text(
            'Duration (minutes):',          // Label for duration input.
            style: TextStyle(fontSize: 18), // Style for the label.
          ),
          TextField(
            controller: durationController,     // Text field to input the workout duration.
            keyboardType: TextInputType.number, // Keyboard for duration input.
            decoration: InputDecoration(
              hintText: 'Enter duration',       // Placeholder text for duration text field.
            ),
          ),
          SizedBox(height: 20),         // Spacing between duration input and log workout button.
          ElevatedButton(
            onPressed: logWorkout,      // Function to log the workout entry.
            child: Text('Log Workout'), // Text for the button.
          ),
          SizedBox(height: 20), // Spacing between log workout button and logged workout list.
          Text(
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