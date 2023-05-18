import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:incognito_music/CustomWidgets/bouncy_playlist_header_scroll_view.dart';
import 'package:incognito_music/CustomWidgets/copy_clipboard.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/miniplayer.dart';
import 'package:incognito_music/CustomWidgets/playlist_popupmenu.dart';
import 'package:incognito_music/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:incognito_music/Services/player_service.dart';
import 'package:incognito_music/Services/youtube_services.dart';
import 'package:incognito_music/Services/yt_music.dart';
import 'package:logging/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class YoutubePlaylist extends StatefulWidget {
  final String playlistId;
  final String type;
  const YoutubePlaylist({Key? key,required this.playlistId,
    this.type = 'playlist',}) : super(key: key);

  @override
  State<YoutubePlaylist> createState() => _YoutubePlaylistState();
}

class _YoutubePlaylistState extends State<YoutubePlaylist> {
   bool status = false;
  List<Map> searchedList = [];
  bool fetched = false;
  bool done = true;
  final ScrollController _scrollController = ScrollController();
  String playlistName = '';
  String playlistSubtitle = '';
  String? playlistSecondarySubtitle;
  String playlistImage = '';

  @override
  void initState() {
    if (!status) {
      status = true;
      if (widget.type == 'playlist') {
        YtMusicService().getPlaylistDetails(widget.playlistId).then((value) {
          setState(() {
            try {
              searchedList = value['songs'] as List<Map>? ?? [];
              playlistName = value['name'] as String? ?? '';
              playlistSubtitle = value['subtitle'] as String? ?? '';
              playlistSecondarySubtitle = value['description'] as String?;
              playlistImage = (value['images'] as List?)?.last as String? ?? '';
              fetched = true;
            } catch (e) {
              Logger.root.severe('Error in fetching playlist details', e);
              fetched = true;
            }
          });
        });
      } else if (widget.type == 'album') {
        YtMusicService().getAlbumDetails(widget.playlistId).then((value) {
          setState(() {
            try {
              searchedList = value['songs'] as List<Map>? ?? [];
              playlistName = value['name'] as String? ?? '';
              playlistSubtitle = value['subtitle'] as String? ?? '';
              playlistSecondarySubtitle = value['description'] as String?;
              playlistImage = (value['images'] as List?)?.last as String? ?? '';
              fetched = true;
            } catch (e) {
              Logger.root.severe('Error in fetching playlist details', e);
              fetched = true;
            }
          });
        });
      } else if (widget.type == 'artist') {
        YtMusicService().getArtistDetails(widget.playlistId).then((value) {
          setState(() {
            try {
              searchedList = value['songs'] as List<Map>? ?? [];
              playlistName = value['name'] as String? ?? '';
              playlistSubtitle = value['subtitle'] as String? ?? '';
              playlistSecondarySubtitle = value['description'] as String?;
              playlistImage = (value['images'] as List?)?.last as String? ?? '';
              fetched = true;
            } catch (e) {
              Logger.root.severe('Error in fetching playlist details', e);
              fetched = true;
            }
          });
        });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (!fetched)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    BouncyPlaylistHeaderScrollView(
                      scrollController: _scrollController,
                      title: playlistName,
                      subtitle: playlistSubtitle,
                      secondarySubtitle: playlistSecondarySubtitle,
                      imageUrl: playlistImage,
                      actions: [
                        PlaylistPopupMenu(
                          data: searchedList,
                          title: playlistName,
                        ),
                      ],
                      onPlayTap: () async {
                        setState(() {
                          done = false;
                        });

                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: searchedList.first['id'].toString(),
                          data: searchedList.first,
                        );
                        final List<Map> playList = List.from(searchedList);
                        playList[0] = response!;
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: playList,
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      onShuffleTap: () async {
                        setState(() {
                          done = false;
                        });
                        final List<Map> playList = List.from(searchedList);
                        playList.shuffle();
                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: playList.first['id'].toString(),
                          data: playList.first,
                        );
                        playList[0] = response!;
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: playList,
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      sliverList: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            if (searchedList.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.songs,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ...searchedList.map(
                              (Map entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                  ),
                                  child: ListTile(
                                    leading: widget.type == 'album'
                                        ? null
                                        : Card(
                                            margin: EdgeInsets.zero,
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                5.0,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: SizedBox.square(
                                              dimension: 50,
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                errorWidget: (context, _, __) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                                imageUrl:
                                                    entry['image'].toString(),
                                                placeholder: (context, url) =>
                                                    const Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(
                                                    'assets/cover.jpg',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    title: Text(
                                      entry['title'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onLongPress: () {
                                      copyToClipboard(
                                        context: context,
                                        text: entry['title'].toString(),
                                      );
                                    },
                                    subtitle: entry['subtitle'] == ''
                                        ? null
                                        : Text(
                                            entry['subtitle'].toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                    onTap: () async {
                                      setState(() {
                                        done = false;
                                      });
                                      final Map? response =
                                          await YouTubeServices()
                                              .formatVideoFromId(
                                        id: entry['id'].toString(),
                                        data: entry,
                                      );
                                      setState(() {
                                        done = true;
                                      });
                                      PlayerInvoke.init(
                                        songsList: [response],
                                        index: 0,
                                        isOffline: false,
                                      );
                                      Navigator.pushNamed(context, '/player');
                                    },
                                    trailing:
                                        YtSongTileTrailingMenu(data: entry),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!done)
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GradientContainer(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.useHome,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                    strokeWidth: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .fetchingStream,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}