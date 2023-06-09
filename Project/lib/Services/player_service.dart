import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:incognito_music/APIs/api.dart';
import 'package:incognito_music/Helpers/auto_update_database.dart';
import 'package:logging/logging.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

import '../Helpers/mediaitem_converter.dart';
import '../Screen/Player/audioplayer.dart';
import 'youtube_services.dart';

class PlayerInvoke {
  static final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  static Future<void> init({
    required List songsList,
    required int index,
    bool fromMiniplayer = false,
    bool? isOffline,
    String? itemId,
    bool recommend = true,
    bool fromDownloads = false,
    bool shuffle = false,
    String? playlistBox,
  }) async {
    final int globalIndex = index < 0 ? 0 : index;
    bool? offline = isOffline;
    final List finalList = songsList.toList();
    if (itemId != null) {
      List recommendList = await MusicAPI().getItemSimilarSongs(itemId);
      finalList.addAll(recommendList);
    }
    if (shuffle) finalList.shuffle();
    if (offline == null) {
      if (audioHandler.mediaItem.value?.extras!['url'].startsWith('http')
          as bool) {
        offline = false;
      } else {
        offline = true;
      }
    } else {
      offline = offline;
    }

    if (!fromMiniplayer) {
      if (!Platform.isAndroid) {
        audioHandler.stop();
      }
      if (offline) {
        fromDownloads
            ? setDownValues(finalList, globalIndex)
            : setOffValues(finalList, globalIndex);
      } else {
        setValues(
          finalList,
          globalIndex,
          recommend: recommend,
        );
      }
    }
  }

  static Future<MediaItem> setTags(
    SongModel response,
    Directory tempDir,
  ) async {
    String playTitle = response.title;
    playTitle == ''
        ? playTitle = response.displayNameWOExt
        : playTitle = response.title;
    String playArtist = response.artist!;
    playArtist == '<unknown>'
        ? playArtist = 'Unknown'
        : playArtist = response.artist!;

    final String playAlbum = response.album!;
    final int playDuration = response.duration ?? 180000;
    final String imagePath = '${tempDir.path}/${response.displayNameWOExt}.jpg';

    final MediaItem tempDict = MediaItem(
      id: response.id.toString(),
      album: playAlbum,
      duration: Duration(milliseconds: playDuration),
      title: playTitle.split('(')[0],
      artist: playArtist,
      genre: response.genre,
      artUri: Uri.file(imagePath),
      extras: {
        'url': response.data,
        'date_added': response.dateAdded,
        'date_modified': response.dateModified,
        'size': response.size,
        'year': response.getMap['year'],
      },
    );
    return tempDict;
  }

  static void setOffValues(List response, int index) {
    getTemporaryDirectory().then((tempDir) async {
      final File file = File('${tempDir.path}/cover.jpg');
      if (!await file.exists()) {
        final byteData = await rootBundle.load('assets/cover.jpg');
        await file.writeAsBytes(
          byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
      }
      final List<MediaItem> queue = [];
      for (int i = 0; i < response.length; i++) {
        queue.add(
          await setTags(response[i] as SongModel, tempDir),
        );
      }
      updateNplay(queue, index);
    });
  }

  static void setDownValues(List response, int index) {
    final List<MediaItem> queue = [];
    queue.addAll(
      response.map(
        (song) => MediaItemConverter.downMapToMediaItem(song as Map),
      ),
    );
    updateNplay(queue, index);
  }

  static Future<void> refreshYtLink(Map playItem) async {
    final int expiredAt = int.parse((playItem['expire_at'] ?? '0').toString());
    String id = playItem['id'] ?? playItem['songId'];
    if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 > expiredAt) {
      Logger.root.info(
        'before service | youtube link expired for ${playItem["title"]}',
      );
      if (Hive.box('ytlinkcache').containsKey(id)) {
        final Map cache = await Hive.box('ytlinkcache').get(id) as Map;
        final int expiredAt = int.parse((cache['expire_at'] ?? '0').toString());
        // final String wasCacheEnabled = cache['cached'].toString();
        if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 > expiredAt) {
          Logger.root
              .info('youtube link expired in cache for ${playItem["title"]}');

          final newData = await YouTubeServices().refreshLink(id.toString());
          Logger.root.info(
            'before service | received new link for ${playItem["title"]}',
          );
          if (newData != null) {
            playItem['url'] = newData['url'];
            playItem['duration'] = newData['duration'];
            playItem['expire_at'] = newData['expire_at'];
          }
        } else {
          Logger.root
              .info('youtube link found in cache for ${playItem["title"]}');
          playItem['url'] = cache['url'];
          playItem['expire_at'] = cache['expire_at'];
        }
      } else {
        final newData = await YouTubeServices().refreshLink(id.toString());
        Logger.root.info(
          'before service | received new link for ${playItem["title"]}',
        );
        if (newData != null) {
          playItem['url'] = newData['url'];
          playItem['duration'] = newData['duration'];
          playItem['expire_at'] = newData['expire_at'];
        }
      }
    }
  }

  static Future<void> setValues(
    List response,
    int index, {
    bool recommend = true,
  }) async {
    final List<MediaItem> queue = [];
    final Map playItem = response[index] as Map;
    final Map? nextItem =
        index == response.length - 1 ? null : response[index + 1] as Map;
    if (playItem['genre'] == 'YouTube') {
      await refreshYtLink(playItem);
    }
    if (nextItem != null && nextItem['genre'] == 'YouTube') {
      await refreshYtLink(nextItem);
    }

    queue.addAll(
      response.map(
        (song) => MediaItemConverter.mapToMediaItem(
          song as Map,
          autoplay: recommend,
        ),
      ),
    );
    await updateNplay(queue, index);
  }

  static Future<void> updateNplay(List<MediaItem> queue, int index) async {
    await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    await audioHandler.updateQueue(queue);
    for (var element in queue) {
      if (element.genre != 'YouTube') AutoUpdateDB.addSong(element);
    }
    await audioHandler.customAction('skipToMediaItem', {'id': queue[index].id});
    await audioHandler.play();
    final String repeatMode =
        Hive.box('settings').get('repeatMode', defaultValue: 'None').toString();
    final bool enforceRepeat =
        Hive.box('settings').get('enforceRepeat', defaultValue: false) as bool;
    if (enforceRepeat) {
      switch (repeatMode) {
        case 'None':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
          break;
        case 'All':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
          break;
        case 'One':
          audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
          break;
        default:
          break;
      }
    } else {
      audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
      Hive.box('settings').put('repeatMode', 'None');
    }
  }
}
