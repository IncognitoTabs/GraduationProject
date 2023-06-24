import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

class FireBase {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<void> createUser(Map user) async {
    DatabaseReference newUsersRef = ref.child('users').push();
    newUsersRef.set(user);
  }

  Future<void> saveListenStats(Map stat) async {
    final userSnapshot = await ref
        .child('stats')
        .orderByChild('userId')
        .equalTo('${stat['userId']}')
        .get();
    bool isUserExists = await rootFirebaseIsExists(userSnapshot);
    if (isUserExists) {
      final snapshot = await userSnapshot.ref
          .orderByChild('songId')
          .equalTo('${stat['songId']}')
          .get();
      if (snapshot.exists) {
        String statKey = snapshot.children.first.key!;
        Map<String, Object?> updates = {};
        updates["stats/$statKey/listenCount"] = ServerValue.increment(1);
        ref.update(updates);
      } else {
        await ref.child('stats').push().set(stat);
        Logger.root.info('Created new stats');
      }
    } else {
      await ref.child('stats').push().set(stat);
      Logger.root.info('Created new stats');
    }
  }

  Future<bool> isNewUser(String userId) async {
    final userSnapshot =
        await ref.child('stats').orderByChild('userId').equalTo(userId).get();
    bool isUserExists = await rootFirebaseIsExists(userSnapshot);
    return !isUserExists;
  }

  Future<void> addIfNotExist(Map song) async {
    await ref
        .child('songs')
        .orderByChild('id')
        .equalTo('${song['id']}')
        .once()
        .then((value) {
      if (value.snapshot.exists) {
        Logger.root.info('Item ${song['title']} already exists in DB ');
      } else {
        DatabaseReference newSongRef = ref.child('songs').push();
        newSongRef.set(song);
        Logger.root.info('Added song to DB: ${song['title']}');
      }
    });
  }

  Future<bool> rootFirebaseIsExists(DataSnapshot snapshot) async {
    return snapshot.exists ? true : false;
  }
}
