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
    final snapshot = await ref
        .child('stats')
        .orderByChild('userId')
        .equalTo('${stat['userId']}')
        .orderByChild('songId')
        .equalTo('${stat['songId']}')
        .get();
    bool isExists = await rootFirebaseIsExists(snapshot);
    if (isExists) {
      Map<String, Object?> updates = {};
      updates["stats/${stat['userId']}/${stat['songId']}/listenCount"] =
          ServerValue.increment(1);
      ref.update(updates);
      Logger.root.info('Updated stats');
    } else {
      await ref.child('stats').push().set(stat);
      Logger.root.info('Created new stats');
    }
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
    // bool isExists = await rootFirebaseIsExists(snapshot);

    // // Ensure a song is not exists.
    // if (isExists) {
    //   Logger.root.info('Item ${song['title']} already exists in DB ');
    // } else {
    //   DatabaseReference newSongRef = ref.child('songs').push();
    //   newSongRef.set(song);
    //   Logger.root.info('Added song to DB: ${song['title']}');
    // }
  }

  Future<bool> rootFirebaseIsExists(DataSnapshot snapshot) async {
    return snapshot.exists ? true : false;
  }
}
