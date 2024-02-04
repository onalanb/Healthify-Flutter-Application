import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'package:hive/hive.dart';
import 'recording.dart';

// Emotion Recorder Widget
// Allows user to choose from one of 30 hard coded emojis to express how they currently feel.
// Keeps track of their choice and when the emoji was selected, logs their input.
class EmotionRecorder extends StatefulWidget {
  final List<Map<dynamic, dynamic>> emotionLogs;

  const EmotionRecorder({required this.emotionLogs, Key? key}) : super(key: key);

  @override
  _EmotionRecorderState createState() => _EmotionRecorderState();
}

// Stateful widget to record the emotions with emojis.
class _EmotionRecorderState extends State<EmotionRecorder> {
  late List<Map<dynamic, dynamic>> emotionLogs;

  // Hard-coded list of 35 emojis for the user's selection.
  final List<String> emojiList = [
    "😊", "😔", "😍", "😂", "😭", "😡", "😴", "🥳", "😎", "😇",
    "😐", "😬", "😒", "😳", "🤔", "😕", "😱", "😞", "😤", "🥺",
    "🤗", "😋", "😶", "🤢", "😵", "😈", "🙄", "😬", "😰", "🤩",
    "😌", "😅", "😪", "😓", "😖"
  ];

  @override
  void initState() {
    super.initState();
    emotionLogs = widget.emotionLogs;
  }

  // Logs the selected emoji from user and creates a timestamp.
  void logEmotion(String selectedEmoji) {

    // Get an instance of RecordingProvider
    final recordingProvider = Provider.of<RecordingProvider>(context, listen: false);

    var now = DateTime.now();
    var loggedEmotion = {
      'emoji': selectedEmoji,
      'timestamp': now,
    };

    // Record the emotion using the provider
    recordingProvider.record('Emotion');

    // Add the emotion to hive database
    var emotionBox = Hive.box<Map<dynamic, dynamic>>('EmotionBox');
    emotionBox.put(now.millisecondsSinceEpoch.toString(), loggedEmotion);

    // Add the emotion to our local state that shows on the widget
    setState(() {
      emotionLogs.insert(0, loggedEmotion);
    });
  }

  // Widget UI for recording the user's emotions.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'What emoji expresses how you feel?', // Title asking the user to select an emoji.
          style: TextStyle(fontSize: 18),       // Style for the title
        ),
        const SizedBox(height: 20), // Spacing between the title and emoji list.
        Wrap(
          spacing: 10,    // Horizontal space between emojis.
          runSpacing: 10, // Vertical space between emojis.
          children: emojiList.map((emoji) {
            // Mapping the list of emojis to gesture detector widgets.
            return GestureDetector(
              onTap: () => logEmotion(emoji), // Gesture detection to log selected emoji.
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFA7268)), // Border color around each emoji.
                  borderRadius: BorderRadius.circular(8),       // Rounded corners for the emojis.
                ),
                child: Text(
                  emoji,                          // Display the emoji.
                  style: const TextStyle(fontSize: 20), // Size of emoji.
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20), // Spacing between emoji list and logged emotions.
        const Text(
          'Logged Emotions:',                                           // Title for logged emotions.
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Style for title.
        ),
        const SizedBox(height: 10), // Spacing between title and logged emotions list.
        Expanded(
          child: ListView.builder(
            itemCount: emotionLogs.length, // Total number of logged emotions.
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(emotionLogs[index]['emoji']),  // Displays the logged emoji.
                subtitle: Text(
                  'Logged at: ${DateFormat('MM/dd/yyyy hh:mm a').format(emotionLogs[index]['timestamp'])}',  // Displays the timestamp of the logged emotion.
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Delete the emotion from hive database
                    // Add the emotion to hive database
                    var emotionBox = Hive.box<Map<dynamic, dynamic>>('EmotionBox');
                    var emotionKey = (emotionLogs[index]['timestamp'] as DateTime).millisecondsSinceEpoch.toString();
                    emotionBox.delete(emotionKey);
                    print('Deleting key $emotionKey');
                    print('Remaining keys ${emotionBox.keys}');
                    print('Remaining values ${emotionBox.values}');

                    // Delete the emotion from the local list:
                    setState(() {
                      emotionLogs.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}