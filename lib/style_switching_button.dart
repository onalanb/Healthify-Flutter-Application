import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'style_options.dart';
import 'package:flutter/material.dart';

class StyleSwitchingButton extends StatelessWidget {
  final Function interaction;
  final Function getButtonText;

  const StyleSwitchingButton({required this.interaction, required this.getButtonText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styleOption = context.watch<StyleOptions>();

    return styleOption.widgetStyle == WidgetStyle.cupertino ?
      CupertinoButton(
        onPressed: () { interaction(); },
        child: Text(
            getButtonText(),
            style: TextStyle(color: CupertinoColors.destructiveRed)),
        color: CupertinoColors.white,
        padding: EdgeInsets.symmetric(horizontal: 16),
      )
      :
      ElevatedButton(
        onPressed: () { interaction(); },
        child: Text(getButtonText()),
      );
  }
}