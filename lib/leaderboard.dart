import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {

  void deleteMyData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete your data? This action "
              "will delete your account and remove you from the leaderboard."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Call the cloud function that deleted the logged in user
                await FirebaseFunctions.instance.httpsCallable('delete_user_data').call();

                // Close the dialog
                Navigator.of(context).pop();

                // Force rebuild of the widget after deletion
                setState(() {});
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 10),
            child: GestureDetector(
              onTap: () { deleteMyData(context); },
              child: const Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text(
                    'Delete My Data',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserRank>>(
              future: fetchLeaderboard(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<UserRank> users = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      UserRank user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(user.email),
                        subtitle: Text('${user.points} points'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<UserRank>> fetchLeaderboard() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
    await db.collection('leaderboard').orderBy('points', descending: true).get();
    List<UserRank> result = [];

    for (var doc in querySnapshot.docs) {
      String email = doc.get("email");
      int points = doc.get("points").toInt();
      String uid = doc.get("uid");
      result.add(UserRank(email: email, points: points, uid: uid));
    }

    return result;
  }
}

class UserRank {
  final String email;
  final int points;
  final String uid;

  UserRank({required this.email, required this.points, required this.uid});
}
