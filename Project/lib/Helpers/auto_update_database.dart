import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';
import 'package:incognito_music/Helpers/firebase.dart';

class AutoUpdateDB {
  static Future<void> addSong(MediaItem item) async {
    await FireBase().addIfNotExist({
      'id': item.id,
      'artist': item.artist.toString(),
      'album': item.album.toString(),
      'image': item.artUri.toString(),
      'duration': item.duration!.inSeconds.toString(),
      'title': item.title,
      'url': item.extras?['url'].toString(),
      'year': item.extras?['year'].toString(),
      'language': item.extras?['language'].toString(),
      'genre': item.genre?.toString(),
      '320kbps': item.extras?['320kbps'],
      'has_lyrics': item.extras?['has_lyrics'],
      'release_date': item.extras?['release_date'],
      'album_id': item.extras?['album_id'],
      'subtitle': item.extras?['subtitle'],
      'perma_url': item.extras?['perma_url'],
    });
  }

  static Future<void> addStats(String songId) async {
    String userId = Hive.box('settings').get('userId');
    await FireBase().saveListenStats({
      'userId': userId,
      'songId': songId,
      'listenCount': 1,
    });
  }
}
