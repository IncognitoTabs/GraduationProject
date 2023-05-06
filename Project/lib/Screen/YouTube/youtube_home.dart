import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:incognito_music/CustomWidgets/on_hover.dart';
import 'package:incognito_music/Screen/YouTube/youtube_playlist.dart';
import 'package:incognito_music/Screen/YouTube/youtube_search.dart';
import 'package:incognito_music/Services/youtube_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool status = false;
List searchedList = Hive.box('cache').get('ytHome', defaultValue: []) as List;
List headList = Hive.box('cache').get('ytHomeHead', defaultValue: []) as List;

class YouTube extends StatefulWidget {
  const YouTube({super.key});

  @override
  State<YouTube> createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTube>
    with AutomaticKeepAliveClientMixin<YouTube> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) {
      boxSize = 250;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if(searchedList.isEmpty)const Center(child: CircularProgressIndicator(),)
          else
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
            child: Column(children: [
              if(headList.isNotEmpty)
              CarouselSlider.builder(itemCount: headList.length, itemBuilder: (context,index,pageViewIndex)=>GestureDetector(
                onTap: () {
                  Navigator.push(context, PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_,__,___)=>YouTubeSearchPage(
                      query: headList[index]['title'].toString(),
                    )));
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    errorWidget:(context, url, error) {
                      return const Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/ytCover.png'),);
                    },
                    imageUrl: headList[index]['image'].toString(),
                    placeholder: (context, url) => const Image(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/ytCover.png'),),
                  ),
                ),
              ), options: CarouselOptions(
                height: boxSize+20,
                viewportFraction: rotated? .36 : 1.0,
                autoPlay: true,
                enlargeCenterPage: true
              )),
              ListView.builder(itemCount: searchedList.length,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 10),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [Padding(padding: const EdgeInsets.fromLTRB(10, 10, 0, 5), child: Text('${searchedList[index]["title"]}',style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),),),
                      ],
                    ),
                    SizedBox(
                      height: boxSize+10,
                      width: double.infinity,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        itemCount: (searchedList[index]['playlists']as List).length,
                        itemBuilder: (context, idx){
                          final item = searchedList[index]['playlists'][idx];
                          item['subtitle'] = item['type']!='video'?'${item["count"]} Tracks |${"description"}': '${item["count"]} | ${item["description"]}';
                          return GestureDetector(
                            onTap: () {
                              item['type'] == 'video'?
                              Navigator.push(context, PageRouteBuilder(opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) => YouTubeSearchPage(
                                query: item['title'].toString()
                              ),)):Navigator.push(context, PageRouteBuilder(opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) => YoutubePlaylist(
                                 playlistId: item['playlistId'].toString()
                              ),));
                            },
                            child: SizedBox(
                              width: item['type']!='playlist'?(boxSize-30)*(16/9):boxSize-30,
                              child: HoverBox(builder: (BuildContext context, bool isHover, Widget? child) { return Card(
                                          color: isHover
                                              ? null
                                              : Colors.transparent,
                                          elevation: 0,
                                          margin: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: child,
                                        ); },
                              child: Column(
                                children: [
                                  Expanded(child: Stack(
                                    children: [
                                  Positioned.fill(child: Card(elevation: 5,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Image(image: item['type']!= 'playlist'?const AssetImage('assets/ytCover.png'):const AssetImage('assets/cover.jpg')),
                                  imageUrl: item['image'].toString(),
                                  placeholder: (context, url) => Image(image: item['type']!= 'playlist'?const AssetImage('assets/ytCoveer.png'):const AssetImage('assets/cover.jpg')),),)),
                                  if(item['type']=='chart')
                                  Align(alignment: Alignment.centerRight,
                                  child: Container(
                                    color: Colors.black.withOpacity(.75),
                                    width: (boxSize-30)*(16/9)/2.5,
                                    margin: const EdgeInsets.all(4.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(item['count'].toString(), style: const TextStyle(
                                          fontSize: 20,fontWeight:FontWeight.bold,
                                        ),),
                                        const IconButton(onPressed: null,
                                        color: Colors.white, icon: Icon(Icons.playlist_play_rounded,size: 40,))
                                      ]),
                                  ),),
                                ],
                                  )),
                                  Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${item["title"]}',
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  item['subtitle'].toString(),
                                                  textAlign: TextAlign.center,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .color,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                )
                                              ],
                                            ),
                                          ),
                                ]),),
                            ),
                          );
                        }),
                    )
                  ],
                );
              },
              )
            ]),
          ),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              padding: const EdgeInsets.all(5.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              // margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: Offset(1.5, 1.5),
                    // shadow direction: bottom right
                  )
                ],
              ),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: 22 / 7 * 2,
                    child: IconButton(
                      icon: const Icon(
                        Icons.menu_rounded,
                      ),
                      // color: Theme.of(context).iconTheme.color,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .searchYt,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const YouTubeSearchPage(
                  query: '',
                  autofocus: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    if (!status) {
      YouTubeServices().getMusicHome().then((value) {
        status = true;
        if (value.isNotEmpty) {
          setState(() {
            searchedList = value['body'] ?? [];
            headList = value['head'] ?? [];

            Hive.box('cache').put('ytHome', value['body']);
            Hive.box('cache').put('ytHomeHead', value['head']);
          });
        } else {
          status = false;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
