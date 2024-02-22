import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'style_options.dart';
import 'package:flutter/material.dart';

class StyleSwitchingListView extends StatelessWidget {
  final int logSize;
  final Function getTitle;
  final Function getSubtitle;
  final Function onDelete;
  final Function? onUpdate;

  const StyleSwitchingListView({required this.logSize, required this.getTitle, required this.getSubtitle, required this.onDelete, required this.onUpdate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styleOption = context.watch<StyleOptions>();

    return styleOption.widgetStyle == WidgetStyle.cupertino ?
      CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
              logSize, (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CupertinoListTile(
                  title: Text(getTitle(index)),  // Displays the logged emoji.
                  subtitle: Text(getSubtitle(index)),
                  trailing: onUpdate == null ?
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(CupertinoIcons.delete),
                      onPressed: () { onDelete(index); },
                    )
                    :
                    Row (
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoButton (
                          padding: EdgeInsets.zero,
                          child: Icon(Icons.edit),
                          onPressed: () { onUpdate!(index); },
                        ),
                        CupertinoButton (
                          padding: EdgeInsets.zero,
                          child: Icon(Icons.delete),
                          onPressed: () { onDelete(index); },
                        ),
                      ],
                    )
                ),
              ),
            ),
          ),
        ),
      )
      :
      ListView.builder(
        itemCount: logSize, // Total number of logged emotions.
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(getTitle(index)),  // Displays the logged emoji.
            subtitle: Text(getSubtitle(index)),
            trailing: onUpdate == null ?
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () { onDelete(index); },
              )
              :
              Row (
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton (
                    icon: Icon(Icons.edit),
                    onPressed: () { onUpdate!(index); },
                  ),
                  IconButton (
                    icon: Icon(Icons.delete),
                    onPressed: () { onDelete(index); },
                  ),
                ],
              )
          );
        },
      );
  }
}