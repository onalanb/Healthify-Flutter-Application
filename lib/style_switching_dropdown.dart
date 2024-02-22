import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'style_options.dart';
import 'package:flutter/material.dart';

class StyleSwitchingDropDown extends StatelessWidget {
  final List<String> dropDownMenuOptionList;
  final Function getSelectedValue;
  final void Function(String?) onSelect;

  const StyleSwitchingDropDown({required this.dropDownMenuOptionList, required this.getSelectedValue, required this.onSelect, Key? key}) : super(key: key);

  onSelectIndex(int index) {
    onSelect(dropDownMenuOptionList[index]);
  }

  @override
  Widget build(BuildContext context) {
    final styleOption = context.watch<StyleOptions>();
    int initialIndex = dropDownMenuOptionList.indexOf(getSelectedValue()); // Get the index of the initial selected value

    return styleOption.widgetStyle == WidgetStyle.cupertino ?
      Container(
        width: 175,
        child: CupertinoPicker(
          itemExtent: 40, // Adjust item extent as needed
          onSelectedItemChanged: onSelectIndex,
          children: dropDownMenuOptionList.map((option) => Center(child: Text(option))).toList(),
          scrollController: FixedExtentScrollController(initialItem: initialIndex), // Set the initial selected item
        ))
      :
      DropdownButton<String>(
        value: getSelectedValue(),  // Currently selected value.
        onChanged: onSelect,
        items: dropDownMenuOptionList.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      );
  }
}