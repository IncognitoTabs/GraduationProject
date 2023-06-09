import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:incognito_music/CustomWidgets/custom_physics.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/miniplayer.dart';
import 'package:incognito_music/CustomWidgets/snack_bar.dart';
import 'package:incognito_music/CustomWidgets/textinput_dialog.dart';
import 'package:incognito_music/Helpers/supabase.dart';
import 'package:incognito_music/Screen/Home/music.dart';
import 'package:incognito_music/Screen/Library/library.dart';
import 'package:incognito_music/Screen/LocalMusic/downloaded_songs.dart';
import 'package:incognito_music/Screen/Search/search.dart';
import 'package:incognito_music/Screen/Settings/setting.dart';
import 'package:incognito_music/Screen/Top%20Charts/top.dart';
import 'package:incognito_music/Screen/YouTube/youtube_home.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool checked = false;
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  List sectionsToShow = Hive.box('settings').get(
    'sectionsToShow',
    defaultValue: ['Home', 'YouTube', 'Library', 'Settings'],
  ) as List;
  DateTime? backButtonPressTime;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  void callBack() {
    sectionsToShow = Hive.box('settings').get('sectionsToShow',
        defaultValue: ['Home', 'YouTube', 'Library', 'Settings']) as List;
    setState(() {});
  }

  // ignore: unused_element
  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
  }

  void updateUserDetails(String key, dynamic value) {
    final userId = Hive.box('settings').get('userId') as String?;
    SupaBase().updateUserDetails(userId, key, value);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return GradientContainer(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        child: GradientContainer(
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0,
                stretch: true,
                expandedHeight: MediaQuery.of(context).size.height * .2,
                flexibleSpace: FlexibleSpaceBar(
                  title: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.appTitle,
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w500),
                    ),
                    textAlign: TextAlign.end,
                  ),
                  titlePadding: const EdgeInsets.only(bottom: 40.0),
                  centerTitle: true,
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.8),
                          Colors.black.withOpacity(.1),
                        ],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/header-dark.jpg'
                              : 'assets/header.jpg'),
                    ),
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                ListTile(
                  title: Text(AppLocalizations.of(context)!.home,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Icons.home_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                if (Platform.isAndroid)
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.myMusic),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    leading: Icon(
                      MdiIcons.folderMusic,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DownloadedSongs(showPlaylists: true)));
                    },
                  ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.downs),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(Icons.download_done_rounded,
                      color: Theme.of(context).iconTheme.color),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/downloads');
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.playlists),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(
                    Icons.playlist_play_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/playlists');
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.settings),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  leading: Icon(Icons.settings_rounded,
                      color: Theme.of(context).iconTheme.color),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SettingPage(callback: callback)));
                  },
                ),
              ])),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 30, 5, 20),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.madeBy,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => handleWillPop(context),
        child: SafeArea(
          child: Row(
            children: [
              if (rotated)
                ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder:
                      (BuildContext context, int indexValue, Widget? child) {
                    return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height),
                            child: IntrinsicHeight(
                                child: NavigationRail(
                              minWidth: 70.0,
                              groupAlignment: 0.0,
                              backgroundColor:
                                  // Colors.transparent,
                                  Theme.of(context).cardColor,
                              selectedIndex: indexValue,
                              onDestinationSelected: (int index) {
                                _onItemTapped(index);
                              },
                              labelType: screenWidth > 1050
                                  ? NavigationRailLabelType.selected
                                  : NavigationRailLabelType.none,
                              selectedLabelTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelTextStyle: TextStyle(
                                color: Theme.of(context).iconTheme.color,
                              ),
                              selectedIconTheme: Theme.of(context)
                                  .iconTheme
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                              unselectedIconTheme: Theme.of(context).iconTheme,
                              useIndicator: screenWidth < 1050,
                              indicatorColor: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                              leading: screenWidth > 1050
                                  ? null
                                  : Builder(
                                      builder: (context) => Transform.rotate(
                                        angle: 22 / 7 * 2,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).cardColor,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.menu_rounded,
                                            ),
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            onPressed: () {
                                              Scaffold.of(context).openDrawer();
                                            },
                                            tooltip: MaterialLocalizations.of(
                                                    context)
                                                .openAppDrawerTooltip,
                                          ),
                                        ),
                                      ),
                                    ),
                              destinations: [
                                NavigationRailDestination(
                                  icon: const Icon(Icons.home_rounded),
                                  label:
                                      Text(AppLocalizations.of(context)!.home),
                                ),
                                NavigationRailDestination(
                                  icon: const Icon(MdiIcons.youtube),
                                  label: Text(
                                      AppLocalizations.of(context)!.youTube),
                                ),
                                NavigationRailDestination(
                                  icon: const Icon(
                                      Icons.my_library_music_rounded),
                                  label: Text(
                                      AppLocalizations.of(context)!.library),
                                ),
                                if (sectionsToShow.contains('Settings'))
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.settings_rounded),
                                    label: Text(
                                      AppLocalizations.of(context)!.settings,
                                    ),
                                  ),
                                if (sectionsToShow.contains('Top Charts'))
                                  NavigationRailDestination(
                                    icon: const Icon(Icons.trending_up_rounded),
                                    label: Text(
                                      AppLocalizations.of(context)!.topCharts,
                                    ),
                                  ),
                              ],
                            ))));
                  },
                ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        physics: const CustomPhysics(),
                        onPageChanged: (indx) {
                          _selectedIndex.value = indx;
                        },
                        controller: _pageController,
                        children: [
                          Stack(
                            children: [
                              NestedScrollView(
                                physics: const BouncingScrollPhysics(),
                                controller: _scrollController,
                                headerSliverBuilder: (
                                  BuildContext context,
                                  bool innerBoxScrolled,
                                ) {
                                  return <Widget>[
                                    SliverAppBar(
                                      expandedHeight: 135,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      // pinned: true,
                                      toolbarHeight: 65,
                                      // floating: true,
                                      automaticallyImplyLeading: false,
                                      flexibleSpace: LayoutBuilder(
                                        builder: (
                                          BuildContext context,
                                          BoxConstraints constraints,
                                        ) {
                                          return FlexibleSpaceBar(
                                            // collapseMode: CollapseMode.parallax,
                                            background: GestureDetector(
                                              onTap: () async {
                                                await showTextInputDialog(
                                                  context: context,
                                                  title: 'Name',
                                                  initialText: name,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  onSubmitted: (value) {
                                                    Hive.box('settings').put(
                                                      'name',
                                                      value.trim(),
                                                    );
                                                    name = value.trim();
                                                    Navigator.pop(context);
                                                  },
                                                );
                                                setState(() {});
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 60,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 15.0,
                                                        ),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .homeGreet,
                                                          style: TextStyle(
                                                            letterSpacing: 2,
                                                            color: Theme.of(
                                                              context,
                                                            )
                                                                .colorScheme
                                                                .secondary,
                                                            fontSize: 30,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 15.0,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        ValueListenableBuilder(
                                                          valueListenable:
                                                              Hive.box(
                                                            'settings',
                                                          ).listenable(),
                                                          builder: (
                                                            BuildContext
                                                                context,
                                                            Box box,
                                                            Widget? child,
                                                          ) {
                                                            return Text(
                                                              (box.get('name') ==
                                                                          null ||
                                                                      box.get('name') ==
                                                                          '')
                                                                  ? 'Guest'
                                                                  : box
                                                                      .get(
                                                                        'name',
                                                                      )
                                                                      .split(
                                                                        ' ',
                                                                      )[0]
                                                                      .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                letterSpacing:
                                                                    2,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SliverAppBar(
                                      automaticallyImplyLeading: false,
                                      pinned: true,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      stretch: true,
                                      toolbarHeight: 65,
                                      title: Align(
                                        alignment: Alignment.centerRight,
                                        child: AnimatedBuilder(
                                          animation: _scrollController,
                                          builder: (context, child) {
                                            return GestureDetector(
                                              child: AnimatedContainer(
                                                width: (!_scrollController
                                                            .hasClients ||
                                                        _scrollController
                                                                // ignore: invalid_use_of_protected_member
                                                                .positions
                                                                .length >
                                                            1)
                                                    ? MediaQuery.of(context)
                                                        .size
                                                        .width
                                                    : max(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            _scrollController
                                                                .offset
                                                                .roundToDouble(),
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            75,
                                                      ),
                                                height: 55.0,
                                                duration: const Duration(
                                                  milliseconds: 150,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                // margin: EdgeInsets.zero,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                  color: Theme.of(context)
                                                      .cardColor,
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
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Icon(
                                                      CupertinoIcons.search,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!
                                                          .searchText,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .color,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SearchPage(
                                                    query: '',
                                                    fromHome: true,
                                                    autofocus: true,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                body: const MusicHomePage(),
                              ),
                              if (!rotated || screenWidth > 1050)
                                Builder(
                                  builder: (context) => Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      left: 4.0,
                                    ),
                                    child: Transform.rotate(
                                      angle: 22 / 7 * 2,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            Theme.of(context).cardColor,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.menu_rounded,
                                          ),
                                          color:
                                              Theme.of(context).iconTheme.color,
                                          onPressed: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          tooltip:
                                              MaterialLocalizations.of(context)
                                                  .openAppDrawerTooltip,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const YouTube(),
                          const LibraryPage(),
                          if (sectionsToShow.contains('Settings'))
                            SettingPage(callback: callback),
                          if (sectionsToShow.contains('Top Charts'))
                            TopCharts(
                              pageController: _pageController,
                            ),
                        ],
                      ),
                    ),
                    MiniPlayer()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: rotated
          ? null
          : SafeArea(
              child: ValueListenableBuilder(
                valueListenable: _selectedIndex,
                builder: (BuildContext context, int indexValue, Widget? child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 60,
                    child: SalomonBottomBar(
                      currentIndex: indexValue,
                      onTap: (index) {
                        _onItemTapped(index);
                      },
                      items: [
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.home_rounded),
                          title: Text(AppLocalizations.of(context)!.home),
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(MdiIcons.youtube),
                          title: Text(AppLocalizations.of(context)!.youTube),
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(Icons.my_library_music_rounded),
                          title: Text(AppLocalizations.of(context)!.library),
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        if (sectionsToShow.contains('Settings'))
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.settings_rounded),
                            title: Text(AppLocalizations.of(context)!.settings),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        if (sectionsToShow.contains('Top Charts'))
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.trending_up_rounded),
                            title: Text(
                              AppLocalizations.of(context)!.topCharts,
                            ),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    ));
  }

  callback() {
    sectionsToShow = Hive.box('settings').get('sectionsToShow',
        defaultValue: ['Home', 'YouTube', 'Library', 'Settings']) as List;
    setState(() {});
  }
}
