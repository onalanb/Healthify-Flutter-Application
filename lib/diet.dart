import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting

// Diet Recorder Widget
// Allows user to type in what they ate and how much of it they had.
// The amount of food can be input as calories, quantity, or grams.
// Keeps track of how much they ate and when, logs their input.
class DietRecorder extends StatefulWidget {
  final List<Map<String, dynamic>> dietLogs;

  DietRecorder({required this.dietLogs, Key? key}) : super(key: key);

  @override
  _DietRecorderState createState() => _DietRecorderState();
}

// Stateful widget to record diet logs.
class _DietRecorderState extends State<DietRecorder> {
  TextEditingController foodController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late List<Map<String, dynamic>> dietLogs;
  Set<String> foodDropdown = Set();

  String selectedUnit = 'Calories'; // Default unit
  String? selectedEntry; // Selected entry from the dropdown list

  @override
  void initState() {
    super.initState();
    dietLogs = widget.dietLogs;

    // Set the default selected entry to the first entry in dietLogs (if available)
    if (dietLogs.isNotEmpty) {
      selectedEntry = dietLogs[0]['food'];
    }
  }

  // Log user's diet information with a timestamp.
  void logDiet() {
    String food = foodController.text;
    String quantity = quantityController.text;

    if ((food.isNotEmpty || dietLogs.isNotEmpty) && quantity.isNotEmpty) {
      setState(() {
        dietLogs.insert(0, {
          'food': food.isNotEmpty ? food : selectedEntry,
          'quantity': quantity,
          'unit': selectedUnit,
          'timestamp': DateTime.now(),
        });

        if (food.isNotEmpty) {
          foodDropdown.add(food);

          // Update the selected entry to the newly added entry
          selectedEntry = food;
        }

        // Clear the text fields after logging
        foodController.clear();
        quantityController.clear();
      });
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

          Row(
            children: [
              Expanded(
                // Always show the text field for food input
                child: TextField(
                  controller: foodController,   // Text field for input food.
                  decoration: InputDecoration(
                    hintText: dietLogs.isNotEmpty ? 'Enter or select food' : 'Enter food',     // Placeholder text for food input.
                  ),
                ),
              ),
              // Display the dropdown list only if there are previous entries
              if (dietLogs.isNotEmpty)
                DropdownButton<String>(
                  value: selectedEntry,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEntry = newValue;
                    });
                  },
                  items: foodDropdown.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry,
                      child: Text(entry),
                    );
                  }).toList(),
                ),
            ],
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