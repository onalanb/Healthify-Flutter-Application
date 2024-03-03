import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date/time formatting
import 'dart:math'; // For calculating the points (dedication)
import 'package:hive/hive.dart';

// Create a class to represent the user's recording data
class UserRecordingData {
  DateTime lastRecordingTime;
  int recordingPoints;
  String lastRecordingType;

  UserRecordingData({required this.lastRecordingTime, required this.recordingPoints, required this.lastRecordingType});
}

// Create a provider class
class RecordingProvider extends ChangeNotifier {
  late UserRecordingData _userRecordingData;

  RecordingProvider() {
    // Add the diet to hive database
    var recordingProviderBox = Hive.box<dynamic>('RecordingProviderBox');
    var lastRecordingTime = recordingProviderBox.get('lastRecordingTime');
    var recordingPoints = recordingProviderBox.get('recordingPoints');
    var lastRecordingType = recordingProviderBox.get('lastRecordingType');

    if (lastRecordingTime != null) {
      _userRecordingData = UserRecordingData(
        lastRecordingTime: lastRecordingTime as DateTime,
        recordingPoints: recordingPoints as int,
        lastRecordingType: lastRecordingType as String,
      );
    } else {
      _userRecordingData = UserRecordingData(
        lastRecordingTime: DateTime.now(),
        recordingPoints: 0,
        lastRecordingType: '',
      );
    }
  }

  // Maximum points that can be earned
  static const int maxPoints = 480; // Max points is 480 after 8 hours.

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
    int pointsEarned = min(timeDifference.inMinutes, 24 * 60); // One point per minute up to 8 hours (maximum 480)

    // Cap points earned to the maximum
    pointsEarned = min(pointsEarned, maxPoints);

    // Update last recording time
    _userRecordingData.lastRecordingTime = currentTime;

    // Give the user some points (you can adjust the points as needed)
    _userRecordingData.recordingPoints += pointsEarned;

    // Return type
    _userRecordingData.lastRecordingType = recordingType;

    var recordingProviderBox = Hive.box<dynamic>('RecordingProviderBox');
    recordingProviderBox.put('lastRecordingTime', currentTime);
    recordingProviderBox.put('recordingPoints', _userRecordingData.recordingPoints);
    recordingProviderBox.put('lastRecordingType', recordingType);

    if (pointsEarned != 0) { addUserData(_userRecordingData.recordingPoints); }

    // Notify listeners to update widgets that depend on this data
    notifyListeners();
  }

  void addUserData(int points) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    User? userCredential = FirebaseAuth.instance.currentUser;
    String uid = userCredential!.uid;

    // Create a new UserRank
    final user = <String, dynamic>{
      "email": userCredential.email ?? "anonymous",
      "points": points,
      "uid": uid,
    };
    DocumentReference userDocRef = db.collection("leaderboard").doc(uid);
    userDocRef.set(user);
  }

}