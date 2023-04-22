import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:incognito_music/CustomWidgets/add_playlist.dart';
import 'package:incognito_music/CustomWidgets/custom_physics.dart';
import 'package:incognito_music/CustomWidgets/data_search.dart';
import 'package:incognito_music/CustomWidgets/empty_screen.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/miniplayer.dart';
import 'package:incognito_music/CustomWidgets/playlist_head.dart';
import 'package:incognito_music/CustomWidgets/snack_bar.dart';
import 'package:incognito_music/Helpers/audio_query.dart';
import 'package:incognito_music/Screen/LocalMusic/local_playlist.dart';
import 'package:incognito_music/Services/player_service.dart';
import 'package:logging/logging.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class DownloadedSongs extends StatefulWidget {
  final List<SongModel>? cachedSongs;
  final String? title;
  final int? playListId;
  final bool showPlaylists;

  const DownloadedSongs(
      {Key? key,
      this.cachedSongs,
      this.title,
      this.playListId,
      this.showPlaylists = false})
      : super(key: key);

  @override
  State<DownloadedSongs> createState() => _DownloadedSongsState();
}

class _DownloadedSongsState extends State<DownloadedSongs>
    with TickerProviderStateMixin {
  List<SongModel> _songs = [];
  String? tempPath = Hive.box('settings').get('tempDirPath')?.toString();
  final Map<String, List<SongModel>> _albums = {};
  final Map<String, List<SongModel>> _artists = {};
  final Map<String, List<SongModel>> _genres = {};

  final List<String> _sortedAlbumKeysList = [];
  final List<String> _sortedArtistKeysList = [];
  final List<String> _sortedGenreKeysList = [];

  bool added = false;
  int sortValue = Hive.box('settings').get('sortValue', defaultValue: 1) as int;
  int orderValue =
      Hive.box('settings').get('orderValue', defaultValue: 1) as int;
  int albumSortValue =
      Hive.box('settings').get('albumSortValue', defaultValue: 2) as int;
  List dirPaths =
      Hive.box('settings').get('searchPaths', defaultValue: []) as List;
  int minDuration =
      Hive.box('settings').get('minDuration', defaultValue: 10) as int;
  bool includeOrExclude =
      Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool;
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  TabController? _tabController;
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  List<PlaylistModel> playlistDetails = [];

  final Map<int, SongSortType> songSortTypes = {
    0: SongSortType.DISPLAY_NAME,
    1: SongSortType.DATE_ADDED,
    2: SongSortType.ALBUM,
    3: SongSortType.ARTIST,
    4: SongSortType.DURATION,
    5: SongSortType.SIZE,
  };

  final Map<int, OrderType> songOrderTypes = {
    0: OrderType.ASC_OR_SMALLER,
    1: OrderType.DESC_OR_GREATER,
  };
  @override
  void initState() {
    _tabController =
        TabController(length: widget.showPlaylists ? 5 : 4, vsync: this);
    getData();
    super.initState();
  }

  Future<void> getData() async {
    try {
      Logger.root.info('Requeting permission to access local storage');
      await offlineAudioQuery.requestPermission();
      tempPath ??= (await getTemporaryDirectory()).path;
      Logger.root.info('Getting local playlists');
      playlistDetails = await offlineAudioQuery.getPlaylists();
      if (widget.cachedSongs == null) {
        Logger.root.info('Cache empty, calling audioQuery');
        final receivedSongs = await offlineAudioQuery.getSongs(
          sortType: songSortTypes[sortValue],
          orderType: songOrderTypes[orderValue],
        );
        Logger.root.info('Received ${receivedSongs.length} songs, filtering');
        _songs = receivedSongs
            .where(
              (i) =>
                  (i.duration ?? 60000) > 1000 * minDuration 
                  &&(i.isMusic! || i.isPodcast! || i.isAudioBook!) 
                  &&(includeOrExclude
                      ? checkIncludedOrExcluded(i)
                      : !checkIncludedOrExcluded(i))
                  &&(RegExp(r'20').matchAsPrefix(i.displayName, 0)== null),
            )
            .toList();
      } else {
        Logger.root.info('Setting songs to cached songs');
        _songs = widget.cachedSongs!;
      }
      added = true;
      Logger.root.info('got ${_songs.length} songs');
      setState(() {});
      Logger.root.info('setting albums and artists');
      for (int i = 0; i < _songs.length; i++) {
        try {
          if (_albums.containsKey(_songs[i].album ?? 'Unknown')) {
            _albums[_songs[i].album ?? 'Unknown']!.add(_songs[i]);
          } else {
            _albums[_songs[i].album ?? 'Unknown'] = [_songs[i]];
            _sortedAlbumKeysList.add(_songs[i].album ?? 'Unknown');
          }

          if (_artists.containsKey(_songs[i].artist ?? 'Unknown')) {
            _artists[_songs[i].artist ?? 'Unknown']!.add(_songs[i]);
          } else {
            _artists[_songs[i].artist ?? 'Unknown'] = [_songs[i]];
            _sortedArtistKeysList.add(_songs[i].artist ?? 'Unknown');
          }

          if (_genres.containsKey(_songs[i].genre ?? 'Unknown')) {
            _genres[_songs[i].genre ?? 'Unknown']!.add(_songs[i]);
          } else {
            _genres[_songs[i].genre ?? 'Unknown'] = [_songs[i]];
            _sortedGenreKeysList.add(_songs[i].genre ?? 'Unknown');
          }
        } catch (e) {
          Logger.root.severe('Error in sorting songs', e);
        }
      }
      Logger.root.info('albums and artists set');
    } catch (e) {
      Logger.root.severe('Error while get local music', e);
      added = true;
    }
  }

  bool checkIncludedOrExcluded(SongModel song) {
    for (final path in includedExcludedPaths) {
      if (song.data.contains(path.toString())) return true;
    }
    return false;
  }

  Future<void> sortSongs(int sortVal, int order) async {
    Logger.root.info('Sorting songs');
    switch (sortVal) {
      case 0:
        _songs.sort(
          (a, b) => a.displayName.compareTo(b.displayName),
        );
        break;
      case 1:
        _songs.sort(
          (a, b) => a.dateAdded.toString().compareTo(b.dateAdded.toString()),
        );
        break;
      case 2:
        _songs.sort(
          (a, b) => a.album.toString().compareTo(b.album.toString()),
        );
        break;
      case 3:
        _songs.sort(
          (a, b) => a.artist.toString().compareTo(b.artist.toString()),
        );
        break;
      case 4:
        _songs.sort(
          (a, b) => a.duration.toString().compareTo(b.duration.toString()),
        );
        break;
      case 5:
        _songs.sort(
          (a, b) => a.size.toString().compareTo(b.size.toString()),
        );
        break;
      default:
        _songs.sort(
          (a, b) => a.dateAdded.toString().compareTo(b.dateAdded.toString()),
        );
        break;
    }

    if (order == 1) {
      _songs = _songs.reversed.toList();
    }
    Logger.root.info('Done Sorting songs');
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: widget.showPlaylists ? 5 : 4,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text(
                    widget.title ?? AppLocalizations.of(context)!.myMusic,
                  ),
                  bottom: TabBar(
                    isScrollable: widget.showPlaylists,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        text: AppLocalizations.of(context)!.songs,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.albums,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.artists,
                      ),
                      Tab(
                        text: AppLocalizations.of(context)!.genres,
                      ),
                      if (widget.showPlaylists)
                        Tab(
                          text: AppLocalizations.of(context)!.playlists,
                        ),
                      //     Tab(
                      //       text: AppLocalizations.of(context)!.videos,
                      //     )
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.search),
                      tooltip: AppLocalizations.of(context)!.search,
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: DataSearch(
                            data: _songs,
                            tempPath: tempPath!,
                          ),
                        );
                      },
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.sort_rounded),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      onSelected: (int value) async {
                        if (value < 6) {
                          sortValue = value;
                          Hive.box('settings').put('sortValue', value);
                        } else {
                          orderValue = value - 6;
                          Hive.box('settings').put('orderValue', orderValue);
                        }
                        await sortSongs(sortValue, orderValue);
                        setState(() {});
                      },
                      itemBuilder: (context) {
                        final List<String> sortTypes = [
                          AppLocalizations.of(context)!.displayName,
                          AppLocalizations.of(context)!.dateAdded,
                          AppLocalizations.of(context)!.album,
                          AppLocalizations.of(context)!.artist,
                          AppLocalizations.of(context)!.duration,
                          AppLocalizations.of(context)!.size,
                        ];
                        final List<String> orderTypes = [
                          AppLocalizations.of(context)!.inc,
                          AppLocalizations.of(context)!.dec,
                        ];
                        final menuList = <PopupMenuEntry<int>>[];
                        menuList.addAll(
                          sortTypes
                              .map(
                                (e) => PopupMenuItem(
                                  value: sortTypes.indexOf(e),
                                  child: Row(
                                    children: [
                                      if (sortValue == sortTypes.indexOf(e))
                                        Icon(
                                          Icons.check_rounded,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[700],
                                        )
                                      else
                                        const SizedBox(),
                                      const SizedBox(width: 10),
                                      Text(
                                        e,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                        menuList.add(
                          const PopupMenuDivider(
                            height: 10,
                          ),
                        );
                        menuList.addAll(
                          orderTypes
                              .map(
                                (e) => PopupMenuItem(
                                  value:
                                      sortTypes.length + orderTypes.indexOf(e),
                                  child: Row(
                                    children: [
                                      if (orderValue == orderTypes.indexOf(e))
                                        Icon(
                                          Icons.check_rounded,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[700],
                                        )
                                      else
                                        const SizedBox(),
                                      const SizedBox(width: 10),
                                      Text(
                                        e,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                        return menuList;
                      },
                    ),
                  ],
                  centerTitle: true,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.secondary,
                  elevation: 0,
                ),
                body: !added
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : TabBarView(
                        physics: const CustomPhysics(),
                        controller: _tabController,
                        children: [
                          SongsTab(
                            songs: _songs,
                            playlistId: widget.playListId,
                            playlistName: widget.title,
                            tempPath: tempPath!,
                          ),
                          AlbumsTab(
                            albums: _albums,
                            albumsList: _sortedAlbumKeysList,
                            tempPath: tempPath!,
                          ),
                          AlbumsTab(
                            albums: _artists,
                            albumsList: _sortedArtistKeysList,
                            tempPath: tempPath!,
                          ),
                          AlbumsTab(
                            albums: _genres,
                            albumsList: _sortedGenreKeysList,
                            tempPath: tempPath!,
                          ),
                          if (widget.showPlaylists)
                            LocalPlaylists(
                              playlistDetails: playlistDetails,
                              offlineAudioQuery: offlineAudioQuery,
                            ),
                          // videosTab(),
                        ],
                      ),
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

class SongsTab extends StatefulWidget {
  final List<SongModel> songs;
  final int? playlistId;
  final String? playlistName;
  final String tempPath;
  const SongsTab({
    super.key,
    required this.songs,
    required this.tempPath,
    this.playlistId,
    this.playlistName,
  });

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.songs.isEmpty
        ? emptyScreen(
            context,
            3,
            AppLocalizations.of(context)!.nothingTo,
            15.0,
            AppLocalizations.of(context)!.showHere,
            45,
            AppLocalizations.of(context)!.downloadSomething,
            23.0,
          )
        : Column(
            children: [
              PlaylistHead(
                songsList: widget.songs,
                offline: true,
                fromDownloads: false,
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 10),
                  shrinkWrap: true,
                  itemExtent: 70.0,
                  itemCount: widget.songs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: OfflineAudioQuery.offlineArtworkWidget(
                        id: widget.songs[index].id,
                        type: ArtworkType.AUDIO,
                        tempPath: widget.tempPath,
                        fileName: widget.songs[index].displayNameWOExt,
                      ),
                      title: Text(
                        widget.songs[index].title.trim() != ''
                            ? widget.songs[index].title
                            : widget.songs[index].displayNameWOExt,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${widget.songs[index].artist?.replaceAll('<unknown>', 'Unknown') ?? AppLocalizations.of(context)!.unknown} - ${widget.songs[index].album?.replaceAll('<unknown>', 'Unknown') ?? AppLocalizations.of(context)!.unknown}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        onSelected: (int? value) async {
                          if (value == 0) {
                            AddToOffPlaylist().addToOffPlaylist(
                              context,
                              widget.songs[index].id,
                            );
                          }
                          if (value == 1) {
                            await OfflineAudioQuery().removeFromPlaylist(
                              playlistId: widget.playlistId!,
                              audioId: widget.songs[index].id,
                            );
                            ShowSnackBar().showSnackBar(
                              context,
                              '${AppLocalizations.of(context)!.removedFrom} ${widget.playlistName}',
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                const Icon(Icons.playlist_add_rounded),
                                const SizedBox(width: 10.0),
                                Text(
                                  AppLocalizations.of(context)!.addToPlaylist,
                                ),
                              ],
                            ),
                          ),
                          if (widget.playlistId != null)
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_rounded),
                                  const SizedBox(width: 10.0),
                                  Text(AppLocalizations.of(context)!.remove),
                                ],
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        PlayerInvoke.init(
                          songsList: widget.songs,
                          index: index,
                          isOffline: true,
                          recommend: false,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
  }
}

class AlbumsTab extends StatefulWidget {
  final Map<String, List<SongModel>> albums;
  final List<String> albumsList;
  final String tempPath;
  const AlbumsTab({
    super.key,
    required this.albums,
    required this.albumsList,
    required this.tempPath,
  });

  @override
  State<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<AlbumsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      shrinkWrap: true,
      itemExtent: 70.0,
      itemCount: widget.albumsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: OfflineAudioQuery.offlineArtworkWidget(
            id: widget.albums[widget.albumsList[index]]![0].id,
            type: ArtworkType.AUDIO,
            tempPath: widget.tempPath,
            fileName:
                widget.albums[widget.albumsList[index]]![0].displayNameWOExt,
          ),
          title: Text(
            widget.albumsList[index],
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${widget.albums[widget.albumsList[index]]!.length} ${AppLocalizations.of(context)!.songs}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DownloadedSongs(
                  title: widget.albumsList[index],
                  cachedSongs: widget.albums[widget.albumsList[index]]
                ),
              ),
            );
          },
        );
      },
    );
  }
}