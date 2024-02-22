import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'style_options.dart';
import 'package:flutter/material.dart';

class StyleSwitchingTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Function getHintText;

  const StyleSwitchingTextField({required this.controller, required this.keyboardType, required this.getHintText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styleOption = context.watch<StyleOptions>();

    return styleOption.widgetStyle == WidgetStyle.cupertino ?
      CupertinoTextField(
        controller: controller,     // Text field to input the workout duration.
        keyboardType: keyboardType, // Keyboard for input.
        placeholder: getHintText(), // Placeholder text for text field.
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.black),
          borderRadius: BorderRadius.circular(8),
        ),
      )
      :
      TextField(
        controller: controller,     // Text field to input the workout duration.
        keyboardType: keyboardType, // Keyboard for input.
        decoration: InputDecoration(
          hintText: getHintText(),  // Placeholder text for text field.
        ),
      );
  }
}