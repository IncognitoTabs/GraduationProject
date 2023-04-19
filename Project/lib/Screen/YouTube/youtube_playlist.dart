import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class YoutubePlaylist extends StatefulWidget {
  final String playlistId;
  final String type;
  const YoutubePlaylist({Key? key,required this.playlistId,
    this.type = 'playlist',}) : super(key: key);

  @override
  State<YoutubePlaylist> createState() => _YoutubePlaylistState();
}

class _YoutubePlaylistState extends State<YoutubePlaylist> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}