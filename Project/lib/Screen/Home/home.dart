import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hive/hive.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/snack_bar.dart';
import 'package:incognito_music/Helpers/supabase.dart';
import 'package:incognito_music/Screen/LocalMusic/downloaded_songs.dart';
import 'package:incognito_music/Screen/Settings/setting.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
    defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library'],
  ) as List;
  DateTime? backButtonPressTime;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  void callBack() {
    sectionsToShow = Hive.box('settings').get('sectionsToShow',
        defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library']) as List;
    setState(() {});
  }

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
                    Icons.home_max_rounded,
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
    ));
  }

  callback() {
    sectionsToShow = Hive.box('settings').get('sectionsToShow',
        defaultValue: ['Home', 'Top Charts', 'Youtube', 'Library']) as List;
        setState(() {
          
        });
  }
}
