import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<UserRank>>(
        future: fetchLeaderboard(), // Replace fetchLeaderboard with your function to fetch leaderboard data
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
                    child: Text('${index + 1}'), // Display rank
                  ),
                  title: Text(user.email),
                  subtitle: Text('${user.points} points'), // Display points earned
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<UserRank>> fetchLeaderboard() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await db.collection('leaderboard').orderBy('points', descending: true).get();
    List<UserRank> result = [];

    for (var doc in querySnapshot.docs) {
      String email = doc.get("email");
      int points = doc.get("points");
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