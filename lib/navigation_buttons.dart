// NO GRADING NECESSARY HERE. NOT RELEVANT TO HOMEWORK REQUIREMENTS. (NOT HOOKED TO APP YET)
// This is something I added for fun (quality of life change) and am trying to see whether or not I can get to work.
// I will have this function implemented in the next milestone. :)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationButtons extends StatefulWidget {
  const NavigationButtons({Key? key}) : super(key: key);

  @override
  _NavigationButtonsState createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<NavigationButtons> {
  String selectedButton = 'Log Emotion'; // Initially select the first button

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildButton(context, 'Log Emotion'),
        SizedBox(width: 10),
        buildButton(context, 'Log Diet'),
        SizedBox(width: 10),
        buildButton(context, 'Log Workout'),
      ],
    );
  }

  Widget buildButton(BuildContext context, String buttonText) {
    bool isSelected = selectedButton == buttonText;
    String name = '';
    if (buttonText == 'Log Emotion') {
      name = 'emotion';
    } else if (buttonText == 'Log Diet') {
      name = 'diet';
    } else if (buttonText == 'Log Workout') {
      name = 'workout';
    }

    return isSelected
        ? ElevatedButton(
            onPressed: () {
              setState(() {
                selectedButton = buttonText;
              });
              Navigator.pushNamed(context, '/$name');
            },
            child: Text(buttonText),
          )
        : OutlinedButton(
            onPressed: () {
              setState(() {
                selectedButton = buttonText;
              });
              Navigator.pushNamed(context, '/$name');
            },
            child: Text(buttonText),
          );
  }
}
