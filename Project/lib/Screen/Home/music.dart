import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:incognito_music/APIs/api.dart';
import 'package:incognito_music/CustomWidgets/collage.dart';
import 'package:incognito_music/CustomWidgets/horizontal_albumlist.dart';
import 'package:incognito_music/CustomWidgets/horizontal_albumlist_separated.dart';
import 'package:incognito_music/CustomWidgets/like_button.dart';
import 'package:incognito_music/CustomWidgets/on_hover.dart';
import 'package:incognito_music/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:incognito_music/Helpers/extensions.dart';
import 'package:incognito_music/Helpers/firebase.dart';
import 'package:incognito_music/Helpers/format.dart';
import 'package:incognito_music/Helpers/image_resolution_modifier.dart';
import 'package:incognito_music/Screen/Common/song_list.dart';
import 'package:incognito_music/Screen/Library/liked.dart';
import 'package:incognito_music/Screen/Search/artists.dart';
import 'package:incognito_music/Services/player_service.dart';

bool fetched = false;
List preferredLanguage = Hive.box('settings')
    .get('preferredLanguage', defaultValue: ['English']) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List<dynamic> trendingSongs = Hive.box('cache').get('trendingSongs') as List;
List<dynamic> userRecommedSongs =
    Hive.box('cache').get('userRecommedSongs') as List;
List updateTrending = [];
List updateRecommend = [];
bool done = true;
List lists = [
  'recent',
  'playlist',
  'trendings',
  'recommend',
  ...?data['collections']
];

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage>
    with AutomaticKeepAliveClientMixin<MusicHomePage> {
  List selectedArtists =
      Hive.box('settings').get('selectedArtists', defaultValue: []) ?? [];
  List recentList =
      Hive.box('cache').get('recentSongs', defaultValue: []) as List;
  Map likedArtists =
      Hive.box('settings').get('likedArtists', defaultValue: {}) as Map;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  int recentIndex = 0;
  int playlistIndex = 1;

  Future<void> getHomePageData() async {
    String userId =
        Hive.box('settings').get('userId', defaultValue: '') as String;
    updateTrending = await MusicAPI().getTrendingSongs();
    if (updateTrending.isNotEmpty) {
      setState(() {
        Hive.box('cache').put('trendingSongs', updateTrending);
        trendingSongs = updateTrending;
      });
    }
    if (await FireBase().isNewUser(userId) && selectedArtists.isNotEmpty) {
      updateRecommend = await MusicAPI().getRecommendByHobbies(selectedArtists);
      if (updateRecommend.isNotEmpty) {
        setState(() {
          Hive.box('cache').put('userRecommedSongs', updateRecommend);
          userRecommedSongs = updateRecommend;
        });
      }
    } else {
      updateRecommend = await MusicAPI().getUserSimilarSongs(userId);
      if (updateRecommend.isNotEmpty) {
        setState(() {
          Hive.box('cache').put('userRecommedSongs', updateRecommend);
          userRecommedSongs = updateRecommend;
        });
      }
    }
    Map recievedData = await MusicAPI().fetchHomePageData();
    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = [
        'recent',
        'playlist',
        'trendings',
        'recommend',
        ...?data['collections']
      ];
      lists.insert(((lists.length) / 2).round(), 'likedArtists');
    }

    setState(() {});
    recievedData = await FormatResponse.formatPromoLists(data);
    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = [
        'recent',
        'playlist',
        'trendings',
        'recommend',
        ...?data['collections']
      ];
      lists.insert((lists.length / 2).round(), 'likedArtists');
    }
    setState(() {});
  }

  String getSubTitle(Map item) {
    final type = item['type'];
    switch (type) {
      case 'charts':
        return '';
      case 'playlist':
        return 'Playlist • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'Incognito' : item['subtitle'].toString().unescape()}';
      case 'song':
        return 'Single • ${item['artist']?.toString().unescape()}';
      case 'mix':
        return 'Mix • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'Incognito' : item['subtitle'].toString().unescape()}';
      case 'show':
        return 'Podcast • ${(item['subtitle']?.toString() ?? '').isEmpty ? 'Incognito' : item['subtitle'].toString().unescape()}';
      case 'album':
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        if (artists != null) {
          return 'Album • ${artists?.join(', ')?.toString().unescape()}';
        } else if (item['subtitle'] != null && item['subtitle'] != '') {
          return 'Album • ${item['subtitle']?.toString().unescape()}';
        }
        return 'Album';
      default:
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return artists?.join(', ')?.toString().unescape() ?? '';
    }
  }

  int likedCount() {
    return Hive.box('Favorite Songs').length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!fetched) {
      getHomePageData();
      fetched = true;
    }
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) {
      boxSize = 250;
    }
    if (playlistNames.length >= 3) {
      recentIndex = 0;
      playlistIndex = 1;
    } else {
      recentIndex = 1;
      playlistIndex = 0;
    }

    return (data.isEmpty && recentList.isEmpty)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                itemCount: data.isEmpty ? 2 : lists.length,
                itemBuilder: (context, idx) {
                  if (idx == recentIndex) {
                    return (recentList.isEmpty ||
                            !(Hive.box('settings')
                                .get('showRecent', defaultValue: true) as bool))
                        ? const SizedBox()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                    child: Text(
                                      AppLocalizations.of(context)!.lastSession,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              HorizontalAlbumListSeparated(
                                songsList: recentList,
                                onTap: (idx) {
                                  PlayerInvoke.init(
                                      songsList: [recentList[idx]],
                                      index: 0,
                                      isOffline: false);
                                  Navigator.pushNamed(context, '/player');
                                },
                              )
                            ],
                          );
                  }
                  if (idx == playlistIndex) {
                    return (playlistNames.isEmpty ||
                            !(Hive.box('settings').get('showPlaylist',
                                defaultValue: false) as bool) ||
                            (playlistNames.length == 1 &&
                                playlistNames.first == 'Favorite Songs' &&
                                likedCount() == 0))
                        ? const SizedBox()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .yourPlaylists,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: boxSize + 15,
                                child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    itemCount: playlistNames.length,
                                    itemBuilder: (context, index) {
                                      final String name =
                                          playlistNames[index].toString();
                                      final String showName =
                                          playlistDetails.containsKey(name)
                                              ? playlistDetails[name]['name']
                                                      ?.toString() ??
                                                  name
                                              : name;
                                      final String? subtitle = playlistDetails[
                                                      name] ==
                                                  null ||
                                              playlistDetails[name]['count'] ==
                                                  null ||
                                              playlistDetails[name]['count'] ==
                                                  0
                                          ? null
                                          : '${playlistDetails[name]['count']} ${AppLocalizations.of(context)!.songs}';
                                      return GestureDetector(
                                        child: SizedBox(
                                          width: boxSize - 30,
                                          child: HoverBox(
                                              child: (playlistDetails[name] ==
                                                          null ||
                                                      (playlistDetails[name]
                                                                  ['imageList']
                                                              as List)
                                                          .isEmpty)
                                                  ? Card(
                                                      elevation: 5,
                                                      color: Colors.black,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10.0)),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: name ==
                                                              'Favorite Songs'
                                                          ? const Image(
                                                              image: AssetImage(
                                                                  'assets/cover.jpg'))
                                                          : const Image(
                                                              image: AssetImage(
                                                                  'assets/album.png'),
                                                            ))
                                                  : Collage(
                                                      showGrid: true,
                                                      imageList:
                                                          playlistDetails[name]
                                                                  ['imageLists']
                                                              as List,
                                                      placeholderImage:
                                                          'assets/cover.jpg',
                                                      borderRadius: 10.0,
                                                    ),
                                              builder: (BuildContext context,
                                                  bool isHover, Widget? child) {
                                                return Card(
                                                  color: isHover
                                                      ? null
                                                      : Colors.transparent,
                                                  elevation: 0,
                                                  margin: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(children: [
                                                    SizedBox.square(
                                                      dimension: isHover
                                                          ? boxSize - 25
                                                          : boxSize - 30,
                                                      child: child,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            showName,
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          if (subtitle !=
                                                                  null &&
                                                              subtitle
                                                                  .isNotEmpty)
                                                            Text(
                                                              subtitle,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              softWrap: false,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .color,
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    )
                                                  ]),
                                                );
                                              }),
                                        ),
                                        onTap: () async {
                                          Hive.box(name);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => LikedSongs(
                                                      playlistName: name,
                                                      showName: playlistDetails
                                                              .containsKey(name)
                                                          ? playlistDetails[
                                                                          name]
                                                                      ['name']
                                                                  ?.toString() ??
                                                              name
                                                          : name)));
                                        },
                                      );
                                    }),
                              ),
                            ],
                          );
                  }
                  if (lists[idx] == 'likedArtists') {
                    final List likedArtistsList = likedArtists.values.toList();
                    return likedArtists.isEmpty
                        ? const SizedBox()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                    child: Text(
                                      'Liked Artists',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              HorizontalAlbumsList(
                                songsList: likedArtistsList,
                                onTap: (int idx) {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (_, __, ___) =>
                                          ArtistSearchPage(
                                        data: likedArtistsList[idx] as Map,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                  }
                  if (lists[idx] == 'trendings') {
                    return trendingSongs.isEmpty
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                  child: Text(
                                    AppLocalizations.of(context)!.viral,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: boxSize + 15,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    itemCount: trendingSongs.length,
                                    itemBuilder: (context, index) {
                                      Map item;
                                      item = trendingSongs[index] as Map;
                                      final subTitle = item['subtitle'];
                                      if (item.isEmpty) return const SizedBox();
                                      return GestureDetector(
                                        onLongPress: () {
                                          Feedback.forLongPress(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return InteractiveViewer(
                                                child: Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                    AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      content: Card(
                                                        elevation: 5,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  _, __) =>
                                                              const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                              'assets/cover.jpg',
                                                            ),
                                                          ),
                                                          imageUrl: getImageUrl(
                                                            item['image']
                                                                .toString(),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                                'assets/cover.jpg'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        onTap: () async {
                                          List currentSongList = [item];
                                          PlayerInvoke.init(
                                              songsList: currentSongList,
                                              itemId: item['id'],
                                              index: 0,
                                              isOffline: false,
                                              recommend: true);
                                          Navigator.pushNamed(
                                            context,
                                            '/player',
                                          );
                                        },
                                        child: SizedBox(
                                          width: boxSize - 30,
                                          child: HoverBox(
                                            child: Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                errorWidget: (context, _, __) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                                imageUrl: getImageUrl(
                                                  item['image'].toString(),
                                                ),
                                                placeholder: (context, url) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'assets/cover.jpg'),
                                                ),
                                              ),
                                            ),
                                            builder: (
                                              BuildContext context,
                                              bool isHover,
                                              Widget? child,
                                            ) {
                                              return Card(
                                                color: isHover
                                                    ? null
                                                    : Colors.transparent,
                                                elevation: 0,
                                                margin: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        SizedBox.square(
                                                          dimension: isHover
                                                              ? boxSize - 25
                                                              : boxSize - 30,
                                                          child: child,
                                                        ),
                                                        if (isHover)
                                                          Positioned.fill(
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(
                                                                4.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black54,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    DecoratedBox(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .black87,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      1000.0,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .play_arrow_rounded,
                                                                    size: 50.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (item['duration'] !=
                                                            null)
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                if (isHover)
                                                                  LikeButton(
                                                                    mediaItem:
                                                                        null,
                                                                    data: item,
                                                                  ),
                                                                SongTileTrailingMenu(
                                                                  data: item,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            item['title']
                                                                    ?.toString()
                                                                    .unescape() ??
                                                                '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          if (subTitle != '')
                                                            Text(
                                                              subTitle,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              softWrap: false,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .color,
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]);
                  }
                  if (lists[idx] == 'recommend') {
                    return userRecommedSongs.isEmpty
                        ? const SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 10, 0, 5),
                                  child: Text(
                                    AppLocalizations.of(context)!.recommend,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: boxSize + 15,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    itemCount: userRecommedSongs.length,
                                    itemBuilder: (context, index) {
                                      Map item;
                                      item = userRecommedSongs[index] as Map;
                                      final subTitle = item['subtitle'];
                                      if (item.isEmpty) return const SizedBox();
                                      return GestureDetector(
                                        onLongPress: () {
                                          Feedback.forLongPress(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return InteractiveViewer(
                                                child: Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                    AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      content: Card(
                                                        elevation: 5,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                                  _, __) =>
                                                              const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                              'assets/cover.jpg',
                                                            ),
                                                          ),
                                                          imageUrl: getImageUrl(
                                                            item['image']
                                                                .toString(),
                                                          ),
                                                          placeholder:
                                                              (context, url) =>
                                                                  const Image(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                                'assets/cover.jpg'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        onTap: () async {
                                          List currentSongList = [item];
                                          PlayerInvoke.init(
                                              songsList: currentSongList,
                                              index: 0,
                                              isOffline: false,
                                              itemId: item['id'],
                                              recommend: true);
                                          Navigator.pushNamed(
                                            context,
                                            '/player',
                                          );
                                        },
                                        child: SizedBox(
                                          width: boxSize - 30,
                                          child: HoverBox(
                                            child: Card(
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                errorWidget: (context, _, __) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                                imageUrl: getImageUrl(
                                                  item['image'].toString(),
                                                ),
                                                placeholder: (context, url) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                      'assets/cover.jpg'),
                                                ),
                                              ),
                                            ),
                                            builder: (
                                              BuildContext context,
                                              bool isHover,
                                              Widget? child,
                                            ) {
                                              return Card(
                                                color: isHover
                                                    ? null
                                                    : Colors.transparent,
                                                elevation: 0,
                                                margin: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Column(
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        SizedBox.square(
                                                          dimension: isHover
                                                              ? boxSize - 25
                                                              : boxSize - 30,
                                                          child: child,
                                                        ),
                                                        if (isHover)
                                                          Positioned.fill(
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(
                                                                4.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black54,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    DecoratedBox(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .black87,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      1000.0,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .play_arrow_rounded,
                                                                    size: 50.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (item['duration'] !=
                                                            null)
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                if (isHover)
                                                                  LikeButton(
                                                                    mediaItem:
                                                                        null,
                                                                    data: item,
                                                                  ),
                                                                SongTileTrailingMenu(
                                                                  data: item,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10.0,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            item['title']
                                                                    ?.toString()
                                                                    .unescape() ??
                                                                '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          if (subTitle != '')
                                                            Text(
                                                              subTitle,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              softWrap: false,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .color,
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]);
                  }
                  return (data[lists[idx]] == null ||
                          blacklistedHomeSections.contains(
                            data['modules'][lists[idx]]?['title']
                                ?.toString()
                                .toLowerCase(),
                          ))
                      ? const SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                              child: Text(
                                data['modules'][lists[idx]]?['title']
                                        ?.toString()
                                        .unescape() ??
                                    '',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: boxSize + 15,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: (data[lists[idx]] as List).length,
                                itemBuilder: (context, index) {
                                  Map item;
                                  item = data[lists[idx]][index] as Map;
                                  final currentSongList = data[lists[idx]]
                                      .where((e) => e['type'] == 'song')
                                      .toList();
                                  final subTitle = getSubTitle(item);
                                  item['subTitle'] = subTitle;
                                  if (item.isEmpty) return const SizedBox();
                                  return GestureDetector(
                                    onLongPress: () {
                                      Feedback.forLongPress(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return InteractiveViewer(
                                            child: Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      Navigator.pop(context),
                                                ),
                                                AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  content: Card(
                                                    elevation: 5,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      errorWidget:
                                                          (context, _, __) =>
                                                              const Image(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage(
                                                          'assets/cover.jpg',
                                                        ),
                                                      ),
                                                      imageUrl: getImageUrl(
                                                        item['image']
                                                            .toString(),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              Image(
                                                        fit: BoxFit.cover,
                                                        image: (item['type'] ==
                                                                    'playlist' ||
                                                                item['type'] ==
                                                                    'album')
                                                            ? const AssetImage(
                                                                'assets/album.png',
                                                              )
                                                            : item['type'] ==
                                                                    'artist'
                                                                ? const AssetImage(
                                                                    'assets/artist.png',
                                                                  )
                                                                : const AssetImage(
                                                                    'assets/cover.jpg',
                                                                  ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      if (item['type'] == 'song') {
                                        PlayerInvoke.init(
                                          songsList: currentSongList as List,
                                          index: currentSongList.indexWhere(
                                            (e) => e['id'] == item['id'],
                                          ),
                                          isOffline: false,
                                        );
                                      }
                                      item['type'] == 'song'
                                          ? Navigator.pushNamed(
                                              context,
                                              '/player',
                                            )
                                          : Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (_, __, ___) =>
                                                    SongsListPage(
                                                  listItem: item,
                                                ),
                                              ),
                                            );
                                    },
                                    child: SizedBox(
                                      width: boxSize - 30,
                                      child: HoverBox(
                                        child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            errorWidget: (context, _, __) =>
                                                const Image(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                'assets/cover.jpg',
                                              ),
                                            ),
                                            imageUrl: getImageUrl(
                                              item['image'].toString(),
                                            ),
                                            placeholder: (context, url) =>
                                                Image(
                                              fit: BoxFit.cover,
                                              image: (item['type'] ==
                                                          'playlist' ||
                                                      item['type'] == 'album')
                                                  ? const AssetImage(
                                                      'assets/album.png',
                                                    )
                                                  : item['type'] == 'artist'
                                                      ? const AssetImage(
                                                          'assets/artist.png',
                                                        )
                                                      : const AssetImage(
                                                          'assets/cover.jpg',
                                                        ),
                                            ),
                                          ),
                                        ),
                                        builder: (
                                          BuildContext context,
                                          bool isHover,
                                          Widget? child,
                                        ) {
                                          return Card(
                                            color: isHover
                                                ? null
                                                : Colors.transparent,
                                            elevation: 0,
                                            margin: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.0,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    SizedBox.square(
                                                      dimension: isHover
                                                          ? boxSize - 25
                                                          : boxSize - 30,
                                                      child: child,
                                                    ),
                                                    if (isHover)
                                                      Positioned.fill(
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(
                                                            4.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.black54,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          child: Center(
                                                            child: DecoratedBox(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black87,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                  1000.0,
                                                                ),
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .play_arrow_rounded,
                                                                size: 50.0,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (item['type'] ==
                                                            'song' ||
                                                        item['duration'] !=
                                                            null)
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            if (isHover)
                                                              LikeButton(
                                                                mediaItem: null,
                                                                data: item,
                                                              ),
                                                            SongTileTrailingMenu(
                                                              data: item,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        item['title']
                                                                ?.toString()
                                                                .unescape() ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.center,
                                                        softWrap: false,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (subTitle != '')
                                                        Text(
                                                          subTitle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          softWrap: false,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .color,
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                }),
            onRefresh: getHomePageData);
  }

  @override
  bool get wantKeepAlive => true;
}
