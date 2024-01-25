import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'dart:math'; // For calculating the points (dedication)

// Create a class to represent the user's recording data
class UserRecordingData {
  DateTime lastRecordingTime;
  int recordingPoints;
  String lastRecordingType;

  UserRecordingData({required this.lastRecordingTime, required this.recordingPoints, required this.lastRecordingType});
}

// Create a provider class
class RecordingProvider extends ChangeNotifier {
  final UserRecordingData _userRecordingData = UserRecordingData(
    lastRecordingTime: DateTime.now(),
    recordingPoints: 0,
    lastRecordingType: '',
  );

  // Maximum points that can be earned
  static const int maxPoints = 100;

  // Getter for last recording time
  DateTime get lastRecordingTime => _userRecordingData.lastRecordingTime;

  // Format the date and time
  String get formattedLastRecordingTime {
    return DateFormat('dd/MM/yyyy hh:mm a').format(_userRecordingData.lastRecordingTime);
  }

  // Getter for recording points
  int get recordingPoints => _userRecordingData.recordingPoints;

  // Getter for recording type
  String get lastRecordingType => _userRecordingData.lastRecordingType;

  // Method to update recording data
  void record(String recordingType) {
    DateTime currentTime = DateTime.now();
    Duration timeDifference = currentTime.difference(_userRecordingData.lastRecordingTime);

    // Calculate points based on the time difference (adjust the formula as needed)
    int pointsEarned = min(timeDifference.inHours, 24) * 5; // Linear formula, 5 points per hour up to 24 hours

    // Cap points earned to the maximum
    pointsEarned = min(pointsEarned, maxPoints);

    // Update last recording time
    _userRecordingData.lastRecordingTime = currentTime;

    // Give the user some points (you can adjust the points as needed)
    _userRecordingData.recordingPoints += pointsEarned;

    // Return type
    _userRecordingData.lastRecordingType = recordingType;

    // Notify listeners to update widgets that depend on this data
    notifyListeners();
  }
}