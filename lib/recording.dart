import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  late String uid; // uid of the logged in user

  RecordingProvider() {
    User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;
    print('----------------- UID: ${uid} -----------------');
    var recordingProviderBox = Hive.box<dynamic>('RecordingProviderBox');
    var lastRecordingTime = recordingProviderBox.get('${uid}_lastRecordingTime');
    var recordingPoints = recordingProviderBox.get('${uid}_recordingPoints');
    var lastRecordingType = recordingProviderBox.get('${uid}_lastRecordingType');

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

  // This is to refresh the recording provider when a new user logs in (via escape)
  void refreshFromHive() {
    User? user = FirebaseAuth.instance.currentUser;
    uid = user!.uid;
    print('----------------- UID: ${uid} -----------------');
    var recordingProviderBox = Hive.box<dynamic>('RecordingProviderBox');
    var lastRecordingTime = recordingProviderBox.get('${uid}_lastRecordingTime');
    var recordingPoints = recordingProviderBox.get('${uid}_recordingPoints');
    var lastRecordingType = recordingProviderBox.get('${uid}_lastRecordingType');
    if (lastRecordingTime != null) {
      _userRecordingData.lastRecordingTime = lastRecordingTime;
      _userRecordingData.recordingPoints = recordingPoints;
      _userRecordingData.lastRecordingType = lastRecordingType;
    }  else {
      _userRecordingData.lastRecordingTime = DateTime.now();
      _userRecordingData.recordingPoints = 0;
      _userRecordingData.lastRecordingType = '';
    }
    // Notify listeners to update widgets that depend on this data
    notifyListeners();
  }

  // Maximum points that can be earned
  static const int maxPoints = 480; // Max points is 480 after 8 hours.

  // Getter for last recording time
  DateTime get lastRecordingTime => _userRecordingData.lastRecordingTime;

  String get lastRecordingTimeWithUTCOffset {
    Duration offset = lastRecordingTime.timeZoneOffset;
    DateTime utcTime = lastRecordingTime.subtract(offset);
    return DateFormat('dd/MM/yyyy hh:mm a').format(utcTime);
  }

  // Format the date and time
  String get formattedLastRecordingTime {
    return DateFormat('dd/MM/yyyy hh:mm a').format(_userRecordingData.lastRecordingTime);
  }

  // Getter for recording points
  int get recordingPoints => _userRecordingData.recordingPoints;

  // Getter for recording type
  String get lastRecordingType => _userRecordingData.lastRecordingType;

  // Method to update recording data
  void record(String recordingType) async {
    DateTime currentTime = DateTime.now();
    // This calculation is for our local hive DB only
    Duration timeDifference = currentTime.difference(_userRecordingData.lastRecordingTime);

    // Calculate points based on the time difference (adjust the formula as needed)
    int pointsEarned = min(timeDifference.inMinutes, 24 * 60); // One point per minute up to 8 hours (maximum 480)

    // Cap points earned to the maximum
    pointsEarned = min(pointsEarned, maxPoints);

    // I need to do this before updating _userRecordingData.lastRecordingTime
    int points = await calculateAndRecordPointsUsingCloudFunction();

    if (points >= 0) {
      // Update last recording time
      _userRecordingData.lastRecordingTime = currentTime;

      // Give the user some points (this is also be stored locally in hive)
      _userRecordingData.recordingPoints = points;

      // Return type
      _userRecordingData.lastRecordingType = recordingType;

      var recordingProviderBox = Hive.box<dynamic>('RecordingProviderBox');
      recordingProviderBox.put('${uid}_lastRecordingTime', currentTime);
      recordingProviderBox.put('${uid}_recordingPoints', _userRecordingData.recordingPoints);
      recordingProviderBox.put('${uid}_lastRecordingType', recordingType);

      // Notify listeners to update widgets that depend on this data
      notifyListeners();
    }
  }

  // This is where I call the cloud function record_points that runs the business
  // logic to calculate points and store it in firestore DB
  Future<int> calculateAndRecordPointsUsingCloudFunction() async {
    try {
      final HttpsCallable recordPoints = FirebaseFunctions.instance.httpsCallable('record_points');
      final resp = await recordPoints.call({
        'lastTime' : lastRecordingTimeWithUTCOffset,
      });

      return resp.data['points'].toInt();
    } catch (e) {
      print('Error calculating recording points: $e');
    }

    return -1;
  }
}