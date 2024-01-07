// Baran Onalan
// January 6th, 2024

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting

void main() {
  runApp(HealthHabitsApp());
}

class HealthHabitsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthify'),
      ),
      body: RecorderPageView(), // Use the PageView to show recorders
    );
  }
}

class RecorderPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        EmotionRecorder(), // First page - Emotion Recorder
        DietRecorder(), // Second page - Diet Recorder
        WorkoutRecorder(), // Third page - Workout Recorder
      ],
    );
  }
}

// Emotion Recorder
// An emotion recorder. It lets the user choose from one of 24 (or more, if you prefer)
// hard-coded emoji to express how they’re currently feeling. When they submit their choice,
// log the emoji they selected. This widget should also show a list of emoji and datetimes.
// In future assignments, we will use state management and persistence to populate the list,
// but since we haven’t covered those topics yet you can hard-code your own mock data.
class EmotionRecorder extends StatefulWidget {
  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

class _EmotionRecorderState extends State<EmotionRecorder> {
  List<Map<String, dynamic>> emotions = [];

  // Hard-coded list of 30 emojis for selection
  final List<String> emojiList = [
    "😊", "😔", "😍", "😂", "😭", "😡", "😴", "🥳", "😎", "😇",
    "😐", "😬", "😒", "😳", "🤔", "😕", "😱", "😞", "😤", "🥺",
    "🤗", "😋", "😶", "🤢", "😵", "😈", "🙄", "😬", "😰", "🤩"
  ];

  void logEmotion(String selectedEmoji) {
    setState(() {
      emotions.insert(0, {
        'emoji': selectedEmoji,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What emoji expresses how you feel?',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: emojiList.map((emoji) {
            return GestureDetector(
              onTap: () => logEmotion(emoji),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        Text(
          'Logged Emotions:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: emotions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(emotions[index]['emoji']),
                subtitle: Text(
                  'Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(emotions[index]['timestamp'])}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Diet Recorder
// A diet recorder. It lets the user type in what they ate and how much of it
// they ate (two separate inputs). When they submit their choice, log the food
// and quantity they entered.
class DietRecorder extends StatefulWidget {
  @override
  _DietRecorderState createState() => _DietRecorderState();
}

class _DietRecorderState extends State<DietRecorder> {
  TextEditingController foodController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> dietLogs = [];
  String selectedUnit = 'Calories'; // Default unit

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What did you eat today?',
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: foodController,
            decoration: InputDecoration(
              hintText: 'Enter food',
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                  ),
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedUnit,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue!;
                  });
                },
                items: ['Calories', 'Grams', 'Items'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logDiet,
            child: Text('Log Diet'),
          ),
          SizedBox(height: 20),
          Text(
            'Logged Diets:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dietLogs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${dietLogs[index]['food']}'),
                  subtitle: Text(
                    'Quantity: ${dietLogs[index]['quantity']} ${dietLogs[index]['unit']} - Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(dietLogs[index]['timestamp'])}',
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

// Workout Recorder
// A workout recorder. It lets the user choose an exercise from eight (or more, if you prefer)
// hard-coded exercises and enter how much of that exercise they did. When they submit their choice,
// log the exercise they selected and quantity they entered. This widget should also show a list
// of exercises, quantities, and datetimes. In future assignments, we will use state management and
// persistence to populate the list, but since we haven’t covered those topics yet you can hard-code
// your own mock data.
class WorkoutRecorder extends StatefulWidget {
  @override
  _WorkoutRecorderState createState() => _WorkoutRecorderState();
}

class _WorkoutRecorderState extends State<WorkoutRecorder> {
  TextEditingController durationController = TextEditingController();
  List<Map<String, dynamic>> workoutLogs = [];

  // List of predefined exercises
  final List<String> exercises = [
    'Dancing', 'Cycling', 'Running', 'Swimming',
    'Weightlifting', 'Yoga', 'Martial Arts', 'Rowing',
    'Climbing' , 'Jump Rope', 'Parkour', 'Stability Training'
  ];

  String selectedExercise = 'Running'; // Default exercise

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What was your workout today?',
            style: TextStyle(fontSize: 18),
          ),
          DropdownButton<String>(
            value: selectedExercise,
            onChanged: (String? newValue) {
              setState(() {
                selectedExercise = newValue!;
              });
            },
            items: exercises.map((String exercise) {
              return DropdownMenuItem<String>(
                value: exercise,
                child: Text(exercise),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text(
            'Duration (minutes):',
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter duration',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logWorkout,
            child: Text('Log Workout'),
          ),
          SizedBox(height: 20),
          Text(
            'Logged Workouts:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: workoutLogs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${workoutLogs[index]['exercise']}'),
                  subtitle: Text(
                    'Duration: ${workoutLogs[index]['duration']} mins - Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(workoutLogs[index]['timestamp'])}',
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