import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/style_switching_button.dart';
import 'package:flutter_app/style_switching_dropdown.dart';
import 'package:flutter_app/style_switching_list_view.dart';
import 'package:flutter_app/style_switching_text_field.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'recording.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Diet Recorder Widget
// Allows user to type in what they ate and how much of it they had.
// The amount of food can be input as calories, quantity, or grams.
// Keeps track of how much they ate and when, logs their input.
class DietRecorder extends StatefulWidget {
  final List<Map<dynamic, dynamic>> dietLogs;
  final Set<String> foodDropdown;

  DietRecorder({required this.dietLogs, required this.foodDropdown, Key? key}) : super(key: key);

  @override
  _DietRecorderState createState() => _DietRecorderState();
}

/******************************************************************************/

// Stateful widget to record diet logs.
class _DietRecorderState extends State<DietRecorder> {
  TextEditingController foodController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late List<Map<dynamic, dynamic>> dietLogs;
  late Set<String> foodDropdown;

  String? selectedUnit; // Default unit
  String? selectedEntry; // Selected entry from the dropdown list
  int saveIndex = -1; // Remember index for value to be updated

  @override
  void initState() {
    super.initState();
    dietLogs = widget.dietLogs;
    foodDropdown = widget.foodDropdown;

    // Set the default selected entry to the first entry in dietLogs (if available)
    if (dietLogs.isNotEmpty) {
      selectedEntry = dietLogs[0]['food'];
    }
  }

  // Log user's diet information with a timestamp.
  void logDiet() {
    // Get an instance of RecordingProvider
    final recordingProvider = Provider.of<RecordingProvider>(context, listen: false);

    String food = foodController.text;
    String quantity = quantityController.text;

    var now = DateTime.now();
    var loggedDiet = {
      'food': food.isNotEmpty ? food : selectedEntry,
      'quantity': quantity,
      'unit': selectedUnit ?? AppLocalizations.of(context)!.calories,
      'timestamp': now,
    };

    if ((food.isNotEmpty || dietLogs.isNotEmpty) && quantity.isNotEmpty) {
      // Record the diet using the provider
      recordingProvider.record('Diet');

      // Add the diet to hive database
      var dietBox = Hive.box<Map<dynamic, dynamic>>('DietBox');
      dietBox.put(now.millisecondsSinceEpoch.toString(), loggedDiet);

      if (food.isNotEmpty && !foodDropdown.contains(food)) {
        var foodDropdownBox = Hive.box<String>('FoodDropdownBox');
        foodDropdownBox.put(now.millisecondsSinceEpoch.toString(), food); // Key is time, query is here in case I want to delete later.
      }

      // Allows us to set the state for the local change so that it is re-rendered
      setState(() {
        saveIndex = -1;
        dietLogs.insert(0, loggedDiet);

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

  void updateDiet(int index) {
    Map<dynamic, dynamic> log = dietLogs.elementAt(index);
    setState(() {
      foodController.text = log['food'];
      quantityController.text = log['quantity'];
      selectedUnit = log['unit'];
      saveIndex = index;
    });
  }

  void updateDietLog() {
    Map<dynamic, dynamic> log = dietLogs.elementAt(saveIndex);
    String food = foodController.text;
    String quantity = quantityController.text;

    var saveDiet = {
      'food': food.isNotEmpty ? food : selectedEntry,
      'quantity': quantity,
      'unit': selectedUnit ?? AppLocalizations.of(context)!.calories,
      'timestamp': log['timestamp'],
    };

    // Add the diet to hive database
    var dietBox = Hive.box<Map<dynamic, dynamic>>('DietBox');
    dietBox.put(log['timestamp'].millisecondsSinceEpoch.toString(), saveDiet);

    setState(() {
      dietLogs[saveIndex] = saveDiet;
      saveIndex = -1;
    });
  }

  void onDelete(int index) {
    // Delete the diet from hive database
    // Add the diet to hive database
    var dietBox = Hive.box<Map<dynamic, dynamic>>('DietBox');
    var dietKey = (dietLogs[index]['timestamp'] as DateTime).millisecondsSinceEpoch.toString();
    dietBox.delete(dietKey);
    print('Deleting key $dietKey');
    print('Remaining keys ${dietBox.keys}');
    print('Remaining values ${dietBox.values}');
    setState(() {
      dietLogs.removeAt(index);
    });
  }

  String getTitle(int index) {
    return '${dietLogs[index]['food']} (${dietLogs[index]['quantity']} ${dietLogs[index]['unit']})';
  }

  String getSubtitle(int index) {
    return AppLocalizations.of(context)!.loggedAt(dietLogs[index]['timestamp'], dietLogs[index]['timestamp']);
  }

  void unitSelected (String? newValue) {
    setState(() {
      selectedUnit = newValue!; // Updates the selected unit when changed.
    });
  }

  void foodSelected (String? newValue) {
    setState(() {
      selectedEntry = newValue;
    });
  }

  // Widget UI for recording the user's diet information.
  @override
  Widget build(BuildContext context) {
    List<String> units = [AppLocalizations.of(context)!.calories, AppLocalizations.of(context)!.grams, AppLocalizations.of(context)!.items];

    return Padding(
      padding: const EdgeInsets.all(20),  // Padding around the widget.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start (left side) of the column.
        children: [
          Text(
            AppLocalizations.of(context)!.dietQuestion,      // Title asking about the user's diet.
            style: TextStyle(fontSize: 18), // Style for the title.
          ),

          Row(
            children: [
              Expanded(
                // Always show the text field for food input
                child: StyleSwitchingTextField(
                    controller: foodController,
                    keyboardType: TextInputType.text,
                    getHintText: () { return dietLogs.isNotEmpty ? AppLocalizations.of(context)!.enterOrSelectFood : AppLocalizations.of(context)!.enterFood; }),
              ),
              SizedBox(width: 10),
              // Display the dropdown list only if there are previous entries
              if (dietLogs.isNotEmpty)
                StyleSwitchingDropDown(
                    dropDownMenuOptionList: foodDropdown.toList(),
                    getSelectedValue: () { return selectedEntry; },
                    onSelect: foodSelected),
            ],
          ),

          const SizedBox(height: 20), // Spacing between food and quantity input.
          Row(
            children: [
              Expanded(
                child: StyleSwitchingTextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    getHintText: () { return AppLocalizations.of(context)!.quantityHint; }),
              ),
              const SizedBox(width: 10),    // Spacing between quantity input and unit selection.
              StyleSwitchingDropDown(
                  dropDownMenuOptionList: units,
                  getSelectedValue: () { return selectedUnit ?? AppLocalizations.of(context)!.calories; },
                  onSelect: unitSelected),
            ],
          ),
          const SizedBox(height: 20),       // Spacing between unit selection and log diet button.
          Row(
            children: [
              StyleSwitchingButton(interaction: logDiet, getButtonText: () { return AppLocalizations.of(context)!.logDiet; }),
              if (saveIndex >= 0) ...[
                SizedBox(width: 20),
                StyleSwitchingButton(interaction: updateDietLog, getButtonText: () { return AppLocalizations.of(context)!.update; }),
              ],
            ],
          ),
          const SizedBox(height: 20), // Spacing between log diet button and logged diet list.
          Text(
            AppLocalizations.of(context)!.loggedDiets,                    // Title for the list of logged diets.
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for the title.
          ),
          Expanded(
            child: StyleSwitchingListView(logSize: dietLogs.length ,getTitle: getTitle, getSubtitle: getSubtitle, onDelete: onDelete, onUpdate: updateDiet),
          ),
        ],
      ),
    );
  }
}