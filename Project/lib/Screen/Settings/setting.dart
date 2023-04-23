import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:incognito_music/CustomWidgets/copy_clipboard.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/popup.dart';
import 'package:incognito_music/CustomWidgets/snack_bar.dart';
import 'package:incognito_music/Helpers/backup_restore.dart';
import 'package:incognito_music/Helpers/countrycodes.dart';
import 'package:incognito_music/Helpers/picker.dart';
import 'package:incognito_music/Screen/Home/music.dart' as home_screen;
import 'package:incognito_music/Screen/Top Charts/top.dart' as top_screen;

import 'package:incognito_music/CustomWidgets/textinput_dialog.dart';
import 'package:incognito_music/Helpers/config.dart';
import 'package:incognito_music/Screen/Settings/player_gradient.dart';
import 'package:incognito_music/Services/ext_storage_provider.dart';
import 'package:incognito_music/Services/nav.dart';
import 'package:incognito_music/main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingPage extends StatefulWidget {
  final Function? callback;
  const SettingPage({super.key, this.callback});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with AutomaticKeepAliveClientMixin<SettingPage> {
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music') as String;
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/IncognitoMusic/Backups',
  ) as String;
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  String streamingQuality = Hive.box('settings')
      .get('streamingQuality', defaultValue: '96 kbps') as String;
  String ytQuality =
      Hive.box('settings').get('ytQuality', defaultValue: 'Low') as String;
  String downloadQuality = Hive.box('settings')
      .get('downloadQuality', defaultValue: '320 kbps') as String;
  String ytDownloadQuality = Hive.box('settings')
      .get('ytDownloadQuality', defaultValue: 'High') as String;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  String canvasColor =
      Hive.box('settings').get('canvasColor', defaultValue: 'Grey') as String;
  String cardColor =
      Hive.box('settings').get('cardColor', defaultValue: 'Grey900') as String;
  String theme =
      Hive.box('settings').get('theme', defaultValue: 'Default') as String;
  Map userThemes =
      Hive.box('settings').get('userThemes', defaultValue: {}) as Map;
  String region =
      Hive.box('settings').get('region', defaultValue: 'Vietnam') as String;
  bool useProxy =
      Hive.box('settings').get('useProxy', defaultValue: false) as bool;
  String themeColor =
      Hive.box('settings').get('themeColor', defaultValue: 'Teal') as String;
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400) as int;
  int downFilename =
      Hive.box('settings').get('downFilename', defaultValue: 0) as int;
  List<String> languages = ['English', 'Vietnamese'];
  List miniButtonsOrder = Hive.box('settings').get(
    'miniButtonsOrder',
    defaultValue: ['Like', 'Previous', 'Play/Pause', 'Next', 'Download'],
  ) as List;
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList() as List;
  List preferredMiniButtons = Hive.box('settings').get(
    'preferredMiniButtons',
    defaultValue: ['Like', 'Play/Pause', 'Next'],
  )?.toList() as List;
  List<int> preferredCompactNotificationButtons = Hive.box('settings').get(
    'preferredCompactNotificationButtons',
    defaultValue: [1, 2, 3],
  ) as List<int>;
  final ValueNotifier<List> sectionsToShow = ValueNotifier<List>(
    Hive.box('settings').get(
      'sectionsToShow',
      defaultValue: ['Home', 'Top Charts', 'YouTube', 'Library'],
    ) as List,
  );

  @override
  void initState() {
    main();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<String> userThemeList = <String>[
      'Default',
      ...userThemes.keys.map((e) => e as String),
      'Custom'
    ];
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 0,
            stretch: true,
            pinned: true,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.secondary
                : null,
            expandedHeight: MediaQuery.of(context).size.height / 4.5,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent])
                      .createShader(
                          Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                },
                blendMode: BlendMode.dstIn,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.settings,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 80, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GradientCard(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text(
                      AppLocalizations.of(context)!.theme,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  BoxSwitchTile(
                    title: Text(AppLocalizations.of(context)!.darkMode),
                    keyName: 'darkMode',
                    defaultValue: true,
                    onChanged: (bool val, Box box) {
                      box.put('useSystemTheme', false);
                      currentTheme.switchTheme(
                          isDark: val, useSystemTheme: false);
                      switchToCustomTheme();
                    },
                  ),
                  BoxSwitchTile(
                    title: Text(AppLocalizations.of(context)!.useSystemTheme),
                    keyName: 'useSystemTheme',
                    defaultValue: true,
                    onChanged: (bool val, Box box) {
                      currentTheme.switchTheme(useSystemTheme: val);
                      switchToCustomTheme();
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.accent),
                    subtitle: Text('$themeColor,$colorHue'),
                    trailing: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100.0),
                            color: Theme.of(context).colorScheme.secondary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[900]!,
                                blurRadius: 5.0,
                                offset: const Offset(0.0, 3.0),
                              )
                            ]),
                      ),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          final List<String> colors = [
                            'Purple',
                            'Deep Purple',
                            'Indigo',
                            'Blue',
                            'Light Blue',
                            'Cyan',
                            'Teal',
                            'Green',
                            'Light Green',
                            'Lime',
                            'Yellow',
                            'Amber',
                            'Orange',
                            'Deep Orange',
                            'Red',
                            'Pink',
                            'White',
                          ];
                          return BottomGradientContainer(
                              child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            itemCount: colors.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int hue in [100, 200, 400, 700])
                                      GestureDetector(
                                        onTap: () {
                                          themeColor = colors[index];
                                          colorHue = hue;
                                          currentTheme.switchColor(
                                              colors[index], colorHue);
                                          setState(() {});
                                          switchToCustomTheme();
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .125,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .125,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              color: MyTheme()
                                                  .getColor(colors[index], hue),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey[900]!,
                                                    blurRadius: 5.0,
                                                    offset:
                                                        const Offset(0.0, 3.0))
                                              ]),
                                          child: (themeColor == colors[index] &&
                                                  colorHue == hue)
                                              ? const Icon(Icons.done_rounded)
                                              : const SizedBox(),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            },
                          ));
                        },
                      );
                    },
                    dense: true,
                  ),
                  Visibility(
                      visible: Theme.of(context).brightness == Brightness.dark,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.bgGrad),
                            subtitle:
                                Text(AppLocalizations.of(context)!.bgGradSub),
                            trailing: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    gradient: LinearGradient(
                                        colors: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? currentTheme.getBackGradient()
                                            : [
                                                Colors.white,
                                                Theme.of(context).canvasColor
                                              ]),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.white24,
                                          blurRadius: 5.0,
                                          offset: Offset(0.0, 3.0))
                                    ]),
                              ),
                            ),
                            onTap: () {
                              final List<List<Color>> gradients =
                                  currentTheme.backOpt;
                              PopupDialog().showPopup(
                                  context: context,
                                  child: SizedBox(
                                    width: 500,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 30, 0, 10),
                                        itemCount: gradients.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0,
                                                right: 20.0,
                                                bottom: 15.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                settingsBox.put(
                                                    'backGrad', index);
                                                currentTheme.backGrad = index;
                                                widget.callback!();
                                                switchToCustomTheme();
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .125,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .125,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors:
                                                            gradients[index])),
                                                child: (currentTheme
                                                            .getBackGradient() ==
                                                        gradients[index]
                                                    ? const Icon(
                                                        Icons.done_rounded,
                                                      )
                                                    : const SizedBox()),
                                              ),
                                            ),
                                          );
                                        }),
                                  ));
                            },
                            dense: true,
                          ),
                          ListTile(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .bottomGrad,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .bottomGradSub,
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    100.0,
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? currentTheme.getBottomGradient()
                                        : [
                                            Colors.white,
                                            Theme.of(context).canvasColor,
                                          ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white24,
                                      blurRadius: 5.0,
                                      offset: Offset(
                                        0.0,
                                        3.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              final List<List<Color>> gradients =
                                  currentTheme.backOpt;
                              PopupDialog().showPopup(
                                context: context,
                                child: SizedBox(
                                  width: 500,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      30,
                                      0,
                                      10,
                                    ),
                                    itemCount: gradients.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20.0,
                                          right: 20.0,
                                          bottom: 15.0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            settingsBox.put(
                                              'bottomGrad',
                                              index,
                                            );
                                            currentTheme.bottomGrad = index;
                                            switchToCustomTheme();
                                            Navigator.pop(context);
                                            setState(
                                              () {},
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.125,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.125,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                15.0,
                                              ),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: gradients[index],
                                              ),
                                            ),
                                            child: (currentTheme
                                                        .getBottomGradient() ==
                                                    gradients[index])
                                                ? const Icon(
                                                    Icons.done_rounded,
                                                  )
                                                : const SizedBox(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            dense: true,
                          ),
                          ListTile(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .canvasColor,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .canvasColorSub,
                            ),
                            onTap: () {},
                            trailing: DropdownButton(
                              value: canvasColor,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                              underline: const SizedBox(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  switchToCustomTheme();
                                  setState(
                                    () {
                                      currentTheme.switchCanvasColor(newValue);
                                      canvasColor = newValue;
                                    },
                                  );
                                }
                              },
                              items: <String>[
                                'Grey',
                                'Black'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            dense: true,
                          ),
                          ListTile(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .cardColor,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .cardColorSub,
                            ),
                            onTap: () {},
                            trailing: DropdownButton(
                              value: cardColor,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                              underline: const SizedBox(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  switchToCustomTheme();
                                  setState(
                                    () {
                                      currentTheme.switchCardColor(newValue);
                                      cardColor = newValue;
                                    },
                                  );
                                }
                              },
                              items: <String>[
                                'Grey800',
                                'Grey850',
                                'Grey900',
                                'Black'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            dense: true,
                          ),
                        ],
                      )),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.useAmoled),
                    dense: true,
                    onTap: () {
                      currentTheme.switchTheme(
                          useSystemTheme: false, isDark: true);
                      Hive.box('settings').put('darkMode', true);
                      settingsBox.put('backGrad', 4);
                      currentTheme.backGrad = 4;
                      settingsBox.put('cardGrad', 6);
                      currentTheme.cardGrad = 6;
                      settingsBox.put('bottomGrad', 4);
                      currentTheme.switchCanvasColor('Black');
                      canvasColor = 'Black';
                      currentTheme.switchCardColor('Grey900');
                      cardColor = 'Grey900';
                      themeColor = 'White';
                      colorHue = 400;
                      currentTheme.switchColor(themeColor, colorHue);
                    },
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.currentTheme),
                    trailing: DropdownButton(
                      value: theme,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      underline: const SizedBox(),
                      onChanged: (String? themeChoice) {
                        if (themeChoice != null) {
                          const deflt = 'Default';
                          currentTheme.setInitialTheme(themeChoice);
                          setState(() {
                            theme = themeChoice;
                            if (themeChoice == 'Custom') return;
                            final selectedTheme = userThemes[themeChoice];
                            settingsBox.put(
                                'backGrad',
                                themeChoice == deflt
                                    ? 2
                                    : selectedTheme['backGrad']);
                            currentTheme.backGrad = themeChoice == deflt
                                ? 2
                                : selectedTheme['backGrad'] as int;
                            settingsBox.put(
                              'cardGrad',
                              themeChoice == deflt
                                  ? 4
                                  : selectedTheme['cardGrad'],
                            );
                            currentTheme.cardGrad = themeChoice == deflt
                                ? 4
                                : selectedTheme['cardGrad'] as int;

                            settingsBox.put(
                              'bottomGrad',
                              themeChoice == deflt
                                  ? 3
                                  : selectedTheme['bottomGrad'],
                            );
                            currentTheme.bottomGrad = themeChoice == deflt
                                ? 3
                                : selectedTheme['bottomGrad'] as int;
                            currentTheme.switchCanvasColor(
                                themeChoice == deflt
                                    ? 'Grey'
                                    : selectedTheme['canvasColor'] as String,
                                notify: false);
                            canvasColor = themeChoice == deflt
                                ? 'Grey'
                                : selectedTheme['canvasColor'] as String;
                            currentTheme.switchCardColor(
                              themeChoice == deflt
                                  ? 'Grey900'
                                  : selectedTheme['cardColor'] as String,
                              notify: false,
                            );
                            cardColor = themeChoice == deflt
                                ? 'Grey900'
                                : selectedTheme['cardColor'] as String;

                            themeColor = themeChoice == deflt
                                ? 'Teal'
                                : selectedTheme['accentColor'] as String;
                            colorHue = themeChoice == deflt
                                ? 400
                                : selectedTheme['colorHue'] as int;

                            currentTheme.switchColor(
                              themeColor,
                              colorHue,
                              notify: false,
                            );

                            currentTheme.switchTheme(
                              useSystemTheme: !(themeChoice == deflt) &&
                                  selectedTheme['useSystemTheme'] as bool,
                              isDark: themeChoice == deflt ||
                                  selectedTheme['isDark'] as bool,
                            );
                          });
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return userThemeList.map<Widget>((String item) {
                          return Text(item);
                        }).toList();
                      },
                      items: userThemeList
                          .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 2,
                                      child: Text(
                                        value,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  if (value != 'Default' && value != 'Custom')
                                    Flexible(
                                        child: IconButton(
                                      iconSize: 18,
                                      splashRadius: 18,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext builder) =>
                                                AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  title: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .deleteTheme,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ),
                                                  content: Text(
                                                    '${AppLocalizations.of(context)!.deleteTheme}$value?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: Navigator.of(
                                                                context)
                                                            .pop,
                                                        child: Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .cancel)),
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .secondary ==
                                                                Colors.white
                                                            ? Colors.black
                                                            : null,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary,
                                                      ),
                                                      onPressed: () {
                                                        currentTheme
                                                            .deleteTheme(value);
                                                        if (currentTheme
                                                                .getInitialTheme() ==
                                                            value) {
                                                          currentTheme
                                                              .setInitialTheme(
                                                                  'Custom');
                                                          theme = 'Custom';
                                                        }
                                                        setState(() {
                                                          userThemes =
                                                              currentTheme
                                                                  .getThemes();
                                                        });
                                                        ShowSnackBar().showSnackBar(
                                                            context,
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .themeDeleted);
                                                        return Navigator.of(
                                                                context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .delete),
                                                    ),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    )
                                                  ],
                                                ));
                                      },
                                      icon: const Icon(Icons.delete_rounded),
                                    ))
                                ],
                              )))
                          .toList(),
                      isDense: true,
                    ),
                    dense: true,
                  ),
                  Visibility(
                    visible: theme == 'Custom',
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.saveTheme),
                      onTap: () {
                        final initialThemeName =
                            '${AppLocalizations.of(context)!.theme} ${userThemes.length + 1}';
                        showTextInputDialog(
                            context: context,
                            title: AppLocalizations.of(context)!.enterThemeName,
                            keyboardType: TextInputType.text,
                            onSubmitted: (value) {
                              if (value == '') {
                                return;
                              }
                              currentTheme.saveTheme(value);
                              currentTheme.setInitialTheme(value);
                              setState(() {
                                userThemes = currentTheme.getThemes();
                                theme = value;
                              });
                              ShowSnackBar().showSnackBar(context,
                                  AppLocalizations.of(context)!.themeSaved);
                              Navigator.of(context).pop();
                            },
                            initialText: initialThemeName);
                      },
                      dense: true,
                    ),
                  )
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GradientCard(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                    child: Text(
                      AppLocalizations.of(context)!.ui,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  ListTile(
                    title: Text(
                        AppLocalizations.of(context)!.playerScreenBackground),
                    subtitle: Text(AppLocalizations.of(context)!
                        .playerScreenBackgroundSub),
                    dense: true,
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, __, ___) =>
                                  const PlayerGradientSection()));
                    },
                  ),
                  BoxSwitchTile(
                    title: Text(AppLocalizations.of(context)!.useDenseMini),
                    keyName: 'useDenseMini',
                    defaultValue: false,
                    isThreeLine: false,
                    subTitle:
                        Text(AppLocalizations.of(context)!.useDenseMiniSub),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.miniButtons),
                    subtitle:
                        Text(AppLocalizations.of(context)!.miniButtonsSub),
                    dense: true,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final List checked =
                                List.from(preferredMiniButtons);
                            final List<String> order =
                                List.from(miniButtonsOrder);
                            return StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      content: SizedBox(
                                        width: 500,
                                        child: ReorderableListView(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 10),
                                          onReorder: (oldIndex, newIndex) {
                                            if (oldIndex < newIndex) {
                                              newIndex--;
                                            }
                                            final temp =
                                                order.removeAt(oldIndex);
                                            order.insert(newIndex, temp);
                                            setState(
                                              () {},
                                            );
                                          },
                                          header: Center(
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .changeOrder),
                                          ),
                                          children: order
                                              .map((e) => Row(
                                                    key: Key(e),
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ReorderableDragStartListener(
                                                          child: const Icon(Icons
                                                              .drag_handle_rounded),
                                                          index:
                                                              order.indexOf(e)),
                                                      Expanded(
                                                          child: SizedBox(
                                                        child: CheckboxListTile(
                                                          dense: true,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 16.0),
                                                          activeColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          checkColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary ==
                                                                  Colors.white
                                                              ? Colors.black
                                                              : null,
                                                          value: checked
                                                              .contains(e),
                                                          title: Text(e),
                                                          onChanged: (value) {
                                                            setState(
                                                              () {
                                                                value!
                                                                    ? checked
                                                                        .add(e)
                                                                    : checked
                                                                        .remove(
                                                                            e);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ))
                                                    ],
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.grey[700]),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .cancel)),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                        .colorScheme
                                                        .secondary ==
                                                    Colors.white
                                                ? Colors.black
                                                : null,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () {
                                                final List temp = [];
                                                for (int i = 0;
                                                    i < order.length;
                                                    i++) {
                                                  if (checked
                                                      .contains(order[i])) {
                                                    temp.add(order[i]);
                                                  }
                                                }
                                                preferredMiniButtons = temp;
                                                miniButtonsOrder = order;
                                                Navigator.pop(context);
                                                Hive.box('settings').put(
                                                  'preferredMiniButtons',
                                                  preferredMiniButtons,
                                                );
                                                Hive.box('settings').put(
                                                  'miniButtonsOrder',
                                                  order,
                                                );
                                              },
                                            );
                                          },
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .ok,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        )
                                      ],
                                    ));
                          });
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .compactNotificationButtons,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .compactNotificationButtonsSub,
                    ),
                    dense: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final Set<int> checked = {
                            ...preferredCompactNotificationButtons
                          };
                          final List<Map> buttons = [
                            {
                              'name': 'Like',
                              'index': 0,
                            },
                            {
                              'name': 'Previous',
                              'index': 1,
                            },
                            {
                              'name': 'Play/Pause',
                              'index': 2,
                            },
                            {
                              'name': 'Next',
                              'index': 3,
                            },
                            {
                              'name': 'Stop',
                              'index': 4,
                            },
                          ];
                          return StatefulBuilder(
                            builder: (
                              BuildContext context,
                              StateSetter setStt,
                            ) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    15.0,
                                  ),
                                ),
                                content: SizedBox(
                                  width: 500,
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    children: [
                                      Center(
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!
                                              .compactNotificationButtonsHeader,
                                        ),
                                      ),
                                      ...buttons.map((value) {
                                        return CheckboxListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          checkColor: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary ==
                                                  Colors.white
                                              ? Colors.black
                                              : null,
                                          value: checked.contains(
                                            value['index'] as int,
                                          ),
                                          title: Text(
                                            value['name'] as String,
                                          ),
                                          onChanged: (bool? isChecked) {
                                            setStt(
                                              () {
                                                if (isChecked!) {
                                                  while (checked.length >= 3) {
                                                    checked.remove(
                                                      checked.first,
                                                    );
                                                  }

                                                  checked.add(
                                                    value['index'] as int,
                                                  );
                                                } else {
                                                  checked.removeWhere(
                                                    (int element) =>
                                                        element ==
                                                        value['index'],
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        );
                                      })
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.grey[700],
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .cancel,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary ==
                                              Colors.white
                                          ? Colors.black
                                          : null,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          while (checked.length > 3) {
                                            checked.remove(
                                              checked.first,
                                            );
                                          }
                                          preferredCompactNotificationButtons =
                                              checked.toList()..sort();
                                          Navigator.pop(context);
                                          Hive.box('settings').put(
                                            'preferredCompactNotificationButtons',
                                            preferredCompactNotificationButtons,
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!
                                          .ok,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .blacklistedHomeSections,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .blacklistedHomeSectionsSub,
                    ),
                    dense: true,
                    onTap: () {
                      final GlobalKey<AnimatedListState> listKey =
                          GlobalKey<AnimatedListState>();
                      showModalBottomSheet(
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          return BottomGradientContainer(
                            borderRadius: BorderRadius.circular(
                              20.0,
                            ),
                            child: AnimatedList(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                10,
                                0,
                                10,
                              ),
                              key: listKey,
                              initialItemCount:
                                  blacklistedHomeSections.length + 1,
                              itemBuilder: (cntxt, idx, animation) {
                                return (idx == 0)
                                    ? ListTile(
                                        title: Text(
                                          AppLocalizations.of(context)!.addNew,
                                        ),
                                        leading: const Icon(
                                          CupertinoIcons.add,
                                        ),
                                        onTap: () async {
                                          showTextInputDialog(
                                            context: context,
                                            title: AppLocalizations.of(
                                              context,
                                            )!
                                                .enterText,
                                            keyboardType: TextInputType.text,
                                            onSubmitted: (String value) {
                                              Navigator.pop(context);
                                              blacklistedHomeSections.add(
                                                value.trim().toLowerCase(),
                                              );
                                              Hive.box('settings').put(
                                                'blacklistedHomeSections',
                                                blacklistedHomeSections,
                                              );
                                              listKey.currentState!.insertItem(
                                                blacklistedHomeSections.length,
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : SizeTransition(
                                        sizeFactor: animation,
                                        child: ListTile(
                                          leading: const Icon(
                                            CupertinoIcons.folder,
                                          ),
                                          title: Text(
                                            blacklistedHomeSections[idx - 1]
                                                .toString(),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.clear,
                                              size: 15.0,
                                            ),
                                            tooltip: 'Remove',
                                            onPressed: () {
                                              blacklistedHomeSections
                                                  .removeAt(idx - 1);
                                              Hive.box('settings').put(
                                                'blacklistedHomeSections',
                                                blacklistedHomeSections,
                                              );
                                              listKey.currentState!.removeItem(
                                                idx,
                                                (
                                                  context,
                                                  animation,
                                                ) =>
                                                    Container(),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .showPlaylists,
                    ),
                    keyName: 'showPlaylist',
                    defaultValue: true,
                    onChanged: (val, box) {
                      widget.callback!();
                    },
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .showLast,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .showLastSub,
                    ),
                    keyName: 'showRecent',
                    defaultValue: true,
                    onChanged: (val, box) {
                      widget.callback!();
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: sectionsToShow,
                    builder: (
                      BuildContext context,
                      List items,
                      Widget? child,
                    ) {
                      return SwitchListTile(
                        activeColor: Theme.of(context).colorScheme.secondary,
                        title: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .showTopCharts,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(
                            context,
                          )!
                              .showTopChartsSub,
                        ),
                        dense: true,
                        value: items.contains('Top Charts'),
                        onChanged: (val) {
                          if (val) {
                            sectionsToShow.value = [
                              'Home',
                              'Top Charts',
                              'YouTube',
                              'Library'
                            ];
                          } else {
                            sectionsToShow.value = [
                              'Home',
                              'YouTube',
                              'Library',
                              'Settings'
                            ];
                          }
                          settingsBox.put(
                            'sectionsToShow',
                            sectionsToShow.value,
                          );
                          widget.callback!();
                        },
                      );
                    },
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .enableGesture,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .enableGestureSub,
                    ),
                    keyName: 'enableGesture',
                    defaultValue: true,
                    isThreeLine: true,
                  ),
                ],
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GradientCard(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Text(
                      AppLocalizations.of(context)!.musicPlayback,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .musicLang,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .musicLangSub,
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: Text(
                        preferredLanguage.isEmpty
                            ? 'None'
                            : preferredLanguage.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    dense: true,
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          final List checked = List.from(preferredLanguage);
                          return StatefulBuilder(
                            builder: (
                              BuildContext context,
                              StateSetter setStt,
                            ) {
                              return BottomGradientContainer(
                                borderRadius: BorderRadius.circular(
                                  20.0,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          10,
                                          0,
                                          10,
                                        ),
                                        itemCount: languages.length,
                                        itemBuilder: (context, idx) {
                                          return CheckboxListTile(
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            checkColor: Theme.of(context)
                                                        .colorScheme
                                                        .secondary ==
                                                    Colors.white
                                                ? Colors.black
                                                : null,
                                            value: checked.contains(
                                              languages[idx],
                                            ),
                                            title: Text(
                                              languages[idx],
                                            ),
                                            onChanged: (bool? value) {
                                              value!
                                                  ? checked.add(languages[idx])
                                                  : checked.remove(
                                                      languages[idx],
                                                    );
                                              setStt(
                                                () {},
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .cancel,
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () {
                                                preferredLanguage = checked;
                                                Navigator.pop(context);
                                                Hive.box('settings').put(
                                                  'preferredLanguage',
                                                  checked,
                                                );
                                                home_screen.fetched = false;
                                                home_screen.preferredLanguage =
                                                    preferredLanguage;
                                                widget.callback!();
                                              },
                                            );
                                            if (preferredLanguage.isEmpty) {
                                              ShowSnackBar().showSnackBar(
                                                context,
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .noLangSelected,
                                              );
                                            }
                                          },
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!
                                                .ok,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .chartLocation,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .chartLocationSub,
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: Text(
                        region,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    dense: true,
                    onTap: () async {
                      region = await SpotifyCountry()
                          .changeCountry(context: context);
                      setState(
                        () {},
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .streamQuality,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .streamQualitySub,
                    ),
                    onTap: () {},
                    trailing: DropdownButton(
                      value: streamingQuality,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(
                            () {
                              streamingQuality = newValue;
                              Hive.box('settings')
                                  .put('streamingQuality', newValue);
                            },
                          );
                        }
                      },
                      items: <String>['96 kbps', '160 kbps', '320 kbps']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    dense: true,
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .ytStreamQuality,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .ytStreamQualitySub,
                    ),
                    onTap: () {},
                    trailing: DropdownButton(
                      value: ytQuality,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(
                            () {
                              ytQuality = newValue;
                              Hive.box('settings').put('ytQuality', newValue);
                            },
                          );
                        }
                      },
                      items: <String>['Low', 'High']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    dense: true,
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .loadLast,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .loadLastSub,
                    ),
                    keyName: 'loadStart',
                    defaultValue: true,
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .resetOnSkip,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .resetOnSkipSub,
                    ),
                    keyName: 'resetOnSkip',
                    defaultValue: false,
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .enforceRepeat,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .enforceRepeatSub,
                    ),
                    keyName: 'enforceRepeat',
                    defaultValue: false,
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .autoplay,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .autoplaySub,
                    ),
                    keyName: 'autoplay',
                    defaultValue: true,
                    isThreeLine: true,
                  ),
                  BoxSwitchTile(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .cacheSong,
                    ),
                    subTitle: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .cacheSongSub,
                    ),
                    keyName: 'cacheSong',
                    defaultValue: true,
                  ),
                ],
              )),
            ),
            Padding(padding: const EdgeInsets.all(10.0),
            child: GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Text(AppLocalizations.of(context)!.down,
                  style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),)),
                            ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downQuality,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downQualitySub,
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: downloadQuality,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    downloadQuality = newValue;
                                    Hive.box('settings')
                                        .put('downloadQuality', newValue);
                                  },
                                );
                              }
                            },
                            items: <String>['96 kbps', '160 kbps', '320 kbps']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .ytDownQuality,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .ytDownQualitySub,
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: ytDownloadQuality,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    ytDownloadQuality = newValue;
                                    Hive.box('settings')
                                        .put('ytDownloadQuality', newValue);
                                  },
                                );
                              }
                            },
                            items: <String>['Low', 'High']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downLocation,
                          ),
                          subtitle: Text(downloadPath),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            onPressed: () async {
                              downloadPath =
                                  await ExtStorageProvider.getExtStorage(
                                        dirName: 'Music',
                                        writeAccess: true,
                                      ) ??
                                      '/storage/emulated/0/Music';
                              Hive.box('settings')
                                  .put('downloadPath', downloadPath);
                              setState(
                                () {},
                              );
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .reset,
                            ),
                          ),
                          onTap: () async {
                            final String temp = await Picker.selectFolder(
                              context: context,
                              message: AppLocalizations.of(
                                context,
                              )!
                                  .selectDownLocation,
                            );
                            if (temp.trim() != '') {
                              downloadPath = temp;
                              Hive.box('settings').put('downloadPath', temp);
                              setState(
                                () {},
                              );
                            } else {
                              ShowSnackBar().showSnackBar(
                                context,
                                AppLocalizations.of(
                                  context,
                                )!
                                    .noFolderSelected,
                              );
                            }
                          },
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downFilename,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downFilenameSub,
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(
                                    20.0,
                                  ),
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    children: [
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: Text(
                                          '${AppLocalizations.of(context)!.title} - ${AppLocalizations.of(context)!.artist}',
                                        ),
                                        value: downFilename == 0,
                                        selected: downFilename == 0,
                                        onChanged: (bool? val) {
                                          if (val ?? false) {
                                            downFilename = 0;
                                            settingsBox.put('downFilename', 0);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: Text(
                                          '${AppLocalizations.of(context)!.artist} - ${AppLocalizations.of(context)!.title}',
                                        ),
                                        value: downFilename == 1,
                                        selected: downFilename == 1,
                                        onChanged: (val) {
                                          if (val ?? false) {
                                            downFilename = 1;
                                            settingsBox.put('downFilename', 1);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                      CheckboxListTile(
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        title: Text(
                                          AppLocalizations.of(context)!.title,
                                        ),
                                        value: downFilename == 2,
                                        selected: downFilename == 2,
                                        onChanged: (val) {
                                          if (val ?? false) {
                                            downFilename = 2;
                                            settingsBox.put('downFilename', 2);
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createAlbumFold,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createAlbumFoldSub,
                          ),
                          keyName: 'createDownloadFolder',
                          isThreeLine: true,
                          defaultValue: false,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createYtFold,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createYtFoldSub,
                          ),
                          keyName: 'createYoutubeFolder',
                          isThreeLine: true,
                          defaultValue: false,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downLyrics,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .downLyricsSub,
                          ),
                          keyName: 'downloadLyrics',
                          defaultValue: false,
                          isThreeLine: true,
                        ),
                ],
              ),
            ),),
            Padding(padding: const EdgeInsets.all(10.0),
            child: GradientCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                          padding: const EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .others,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .lang,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .langSub,
                          ),
                          onTap: () {},
                          trailing: DropdownButton(
                            value: lang,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                  () {
                                    lang = newValue;
                                    MyApp.of(context).setLocale(
                                      Locale.fromSubtags(
                                        languageCode: ConstantCodes
                                                .languageCodes[newValue] ??
                                            'en',
                                      ),
                                    );
                                    Hive.box('settings').put('lang', newValue);
                                  },
                                );
                              }
                            },
                            items: ConstantCodes.languageCodes.keys
                                .map<DropdownMenuItem<String>>((language) {
                              return DropdownMenuItem<String>(
                                value: language,
                                child: Text(
                                  language,
                                ),
                              );
                            }).toList(),
                          ),
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .includeExcludeFolder,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .includeExcludeFolderSub,
                          ),
                          dense: true,
                          onTap: () {
                            final GlobalKey<AnimatedListState> listKey =
                                GlobalKey<AnimatedListState>();
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return BottomGradientContainer(
                                  borderRadius: BorderRadius.circular(
                                    20.0,
                                  ),
                                  child: AnimatedList(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      10,
                                      0,
                                      10,
                                    ),
                                    key: listKey,
                                    initialItemCount:
                                        includedExcludedPaths.length + 2,
                                    itemBuilder: (cntxt, idx, animation) {
                                      if (idx == 0) {
                                        return ValueListenableBuilder(
                                          valueListenable: includeOrExclude,
                                          builder: (
                                            BuildContext context,
                                            bool value,
                                            Widget? widget,
                                          ) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: <Widget>[
                                                    ChoiceChip(
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .excluded,
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: !value
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                        fontWeight: !value
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: !value,
                                                      onSelected:
                                                          (bool selected) {
                                                        includeOrExclude.value =
                                                            !selected;
                                                        settingsBox.put(
                                                          'includeOrExclude',
                                                          !selected,
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    ChoiceChip(
                                                      label: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!
                                                            .included,
                                                      ),
                                                      selectedColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                              .withOpacity(0.2),
                                                      labelStyle: TextStyle(
                                                        color: value
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .secondary
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                        fontWeight: value
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                      ),
                                                      selected: value,
                                                      onSelected:
                                                          (bool selected) {
                                                        includeOrExclude.value =
                                                            selected;
                                                        settingsBox.put(
                                                          'includeOrExclude',
                                                          selected,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 5.0,
                                                    top: 5.0,
                                                    bottom: 10.0,
                                                  ),
                                                  child: Text(
                                                    value
                                                        ? AppLocalizations.of(
                                                            context,
                                                          )!
                                                            .includedDetails
                                                        : AppLocalizations.of(
                                                            context,
                                                          )!
                                                            .excludedDetails,
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      if (idx == 1) {
                                        return ListTile(
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .addNew,
                                          ),
                                          leading: const Icon(
                                            CupertinoIcons.add,
                                          ),
                                          onTap: () async {
                                            final String temp =
                                                await Picker.selectFolder(
                                              context: context,
                                            );
                                            if (temp.trim() != '' &&
                                                !includedExcludedPaths
                                                    .contains(temp)) {
                                              includedExcludedPaths.add(temp);
                                              Hive.box('settings').put(
                                                'includedExcludedPaths',
                                                includedExcludedPaths,
                                              );
                                              listKey.currentState!.insertItem(
                                                includedExcludedPaths.length,
                                              );
                                            } else {
                                              if (temp.trim() == '') {
                                                Navigator.pop(context);
                                              }
                                              ShowSnackBar().showSnackBar(
                                                context,
                                                temp.trim() == ''
                                                    ? 'No folder selected'
                                                    : 'Already added',
                                              );
                                            }
                                          },
                                        );
                                      }

                                      return SizeTransition(
                                        sizeFactor: animation,
                                        child: ListTile(
                                          leading: const Icon(
                                            CupertinoIcons.folder,
                                          ),
                                          title: Text(
                                            includedExcludedPaths[idx - 2]
                                                .toString(),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              CupertinoIcons.clear,
                                              size: 15.0,
                                            ),
                                            tooltip: 'Remove',
                                            onPressed: () {
                                              includedExcludedPaths
                                                  .removeAt(idx - 2);
                                              Hive.box('settings').put(
                                                'includedExcludedPaths',
                                                includedExcludedPaths,
                                              );
                                              listKey.currentState!.removeItem(
                                                idx,
                                                (context, animation) =>
                                                    Container(),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .minAudioLen,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .minAudioLenSub,
                          ),
                          dense: true,
                          onTap: () {
                            showTextInputDialog(
                              context: context,
                              title: AppLocalizations.of(
                                context,
                              )!
                                  .minAudioAlert,
                              initialText: (Hive.box('settings')
                                          .get('minDuration', defaultValue: 10)
                                      as int)
                                  .toString(),
                              keyboardType: TextInputType.number,
                              onSubmitted: (String value) {
                                if (value.trim() == '') {
                                  value = '0';
                                }
                                Hive.box('settings')
                                    .put('minDuration', int.parse(value));
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .liveSearch,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .liveSearchSub,
                          ),
                          keyName: 'liveSearch',
                          isThreeLine: false,
                          defaultValue: true,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .useDown,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .useDownSub,
                          ),
                          keyName: 'useDown',
                          isThreeLine: true,
                          defaultValue: true,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .getLyricsOnline,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .getLyricsOnlineSub,
                          ),
                          keyName: 'getLyricsOnline',
                          isThreeLine: true,
                          defaultValue: true,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .supportEq,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .supportEqSub,
                          ),
                          keyName: 'supportEq',
                          isThreeLine: true,
                          defaultValue: false,
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .stopOnClose,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .stopOnCloseSub,
                          ),
                          isThreeLine: true,
                          keyName: 'stopForegroundService',
                          defaultValue: true,
                        ),
                        // const BoxSwitchTile(
                        //   title: Text('Remove Service from foreground when paused'),
                        //   subtitle: Text(
                        //       "If turned on, you can slide notification when paused to stop the service. But Service can also be stopped by android to release memory. If you don't want android to stop service while paused, turn it off\nDefault: On\n"),
                        //   isThreeLine: true,
                        //   keyName: 'stopServiceOnPause',
                        //   defaultValue: true,
                        // ),
              ],
            )),),
            Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10.0,
                    10.0,
                    10.0,
                  ),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .backNRest,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createBack,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .createBackSub,
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                final List playlistNames =
                                    Hive.box('settings').get(
                                  'playlistNames',
                                  defaultValue: ['Favorite Songs'],
                                ) as List;
                                if (!playlistNames.contains('Favorite Songs')) {
                                  playlistNames.insert(0, 'Favorite Songs');
                                  settingsBox.put(
                                    'playlistNames',
                                    playlistNames,
                                  );
                                }

                                final List<String> persist = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                ];

                                final List<String> checked = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                ];

                                final List<String> items = [
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs,
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .cache,
                                ];

                                final Map<String, List> boxNames = {
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .settings: ['settings'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .cache: ['cache'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .downs: ['downloads'],
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .playlists: playlistNames,
                                };
                                return StatefulBuilder(
                                  builder: (
                                    BuildContext context,
                                    StateSetter setStt,
                                  ) {
                                    return BottomGradientContainer(
                                      borderRadius: BorderRadius.circular(
                                        20.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                0,
                                                10,
                                                0,
                                                10,
                                              ),
                                              itemCount: items.length,
                                              itemBuilder: (context, idx) {
                                                return CheckboxListTile(
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  checkColor: Theme.of(context)
                                                              .colorScheme
                                                              .secondary ==
                                                          Colors.white
                                                      ? Colors.black
                                                      : null,
                                                  value: checked.contains(
                                                    items[idx],
                                                  ),
                                                  title: Text(
                                                    items[idx],
                                                  ),
                                                  onChanged: persist
                                                          .contains(items[idx])
                                                      ? null
                                                      : (bool? value) {
                                                          value!
                                                              ? checked.add(
                                                                  items[idx],
                                                                )
                                                              : checked.remove(
                                                                  items[idx],
                                                                );
                                                          setStt(
                                                            () {},
                                                          );
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!
                                                      .cancel,
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                ),
                                                onPressed: () {
                                                  createBackup(
                                                    context,
                                                    checked,
                                                    boxNames,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!
                                                      .ok,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .restore,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .restoreSub,
                          ),
                          dense: true,
                          onTap: () async {
                            await restore(context);
                            currentTheme.refresh();
                          },
                        ),
                        BoxSwitchTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .autoBack,
                          ),
                          subTitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .autoBackSub,
                          ),
                          keyName: 'autoBackup',
                          defaultValue: false,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .autoBackLocation,
                          ),
                          subtitle: Text(autoBackPath),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            onPressed: () async {
                              autoBackPath =
                                  await ExtStorageProvider.getExtStorage(
                                        dirName: 'IncognitoMusic/Backups',
                                        writeAccess: true,
                                      ) ??
                                      '/storage/emulated/0/IncognitoMusic/Backups';
                              Hive.box('settings')
                                  .put('autoBackPath', autoBackPath);
                              setState(
                                () {},
                              );
                            },
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!
                                  .reset,
                            ),
                          ),
                          onTap: () async {
                            final String temp = await Picker.selectFolder(
                              context: context,
                              message: AppLocalizations.of(
                                context,
                              )!
                                  .selectBackLocation,
                            );
                            if (temp.trim() != '') {
                              autoBackPath = temp;
                              Hive.box('settings').put('autoBackPath', temp);
                              setState(
                                () {},
                              );
                            } else {
                              ShowSnackBar().showSnackBar(
                                context,
                                AppLocalizations.of(
                                  context,
                                )!
                                    .noFolderSelected,
                              );
                            }
                          },
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            15,
                            15,
                            15,
                            0,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .about,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .shareApp,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .shareAppSub,
                          ),
                          onTap: () {
                            Share.share(
                              '${AppLocalizations.of(
                                context,
                              )!.shareAppText}: https://github.com/IncognitoTabs/GraduationProject.git',
                            );
                          },
                          dense: true,
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .contactUs,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .contactUsSub,
                          ),
                          dense: true,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 100,
                                  child: GradientContainer(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                MdiIcons.gmail,
                                              ),
                                              iconSize: 40,
                                              tooltip: AppLocalizations.of(
                                                context,
                                              )!
                                                  .gmail,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                launchUrl(
                                                  Uri.parse(
                                                    'https://mail.google.com/mail/?extsrc=mailto&url=mailto%3A%3Fto%3Dhoangminhtai2810%40gmail.com%26subject%3DRegarding%2520IncognitoMusic%2520App',
                                                  ),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              },
                                            ),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .gmail,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                MdiIcons.linkedin,
                                              ),
                                              iconSize: 40,
                                              tooltip: AppLocalizations.of(
                                                context,
                                              )!
                                                  .tg,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                launchUrl(
                                                  Uri.parse(
                                                    'https://www.linkedin.com/in/incognitotabs/',
                                                  ),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              },
                                            ),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .tg,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                MdiIcons.instagram,
                                              ),
                                              iconSize: 40,
                                              tooltip: AppLocalizations.of(
                                                context,
                                              )!
                                                  .insta,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                launchUrl(
                                                  Uri.parse(
                                                    'https://www.instagram.com/tabsvn/',
                                                  ),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              },
                                            ),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!
                                                  .insta,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!
                                .moreInfo,
                          ),
                          dense: true,
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            Padding(
                  padding: const EdgeInsets.fromLTRB(
                    5,
                    30,
                    5,
                    20,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .madeBy,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
          ]))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => sectionsToShow.value.contains('Settings');

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  void switchToCustomTheme() {
    const custom = 'Custom';
    if (theme != custom) {
      currentTheme.setInitialTheme(custom);
      setState(() {
        theme = custom;
      });
    }
  }
}

class BoxSwitchTile extends StatelessWidget {
  final Text title;
  final Text? subTitle;
  final String keyName;
  final bool defaultValue;
  final bool? isThreeLine;
  final Function(bool, Box box)? onChanged;

  const BoxSwitchTile({
    super.key,
    required this.title,
    this.subTitle,
    required this.keyName,
    required this.defaultValue,
    this.isThreeLine,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box('settings').listenable(),
        builder: (BuildContext context, Box box, Widget? widget) {
          return SwitchListTile(
            value: box.get(keyName, defaultValue: defaultValue) as bool? ??
                defaultValue,
            onChanged: (val) {
              box.put(keyName, val);
              onChanged!.call(val, box);
            },
            activeColor: Theme.of(context).colorScheme.secondary,
            title: title,
            subtitle: subTitle,
            isThreeLine: isThreeLine ?? false,
            dense: true,
          );
        });
  }
}
class SpotifyCountry {
  Future<String> changeCountry({required BuildContext context}) async {
    String region =
        Hive.box('settings').get('region', defaultValue: 'Vietnam') as String;
    if (!ConstantCodes.localChartCodes.containsKey(region)) {
      region = 'Vietnam';
    }

    await showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        const Map<String, String> codes = ConstantCodes.localChartCodes;
        final List<String> countries = codes.keys.toList();
        return BottomGradientContainer(
          borderRadius: BorderRadius.circular(
            20.0,
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              10,
              0,
              10,
            ),
            itemCount: countries.length,
            itemBuilder: (context, idx) {
              return ListTileTheme(
                selectedColor: Theme.of(context).colorScheme.secondary,
                child: ListTile(
                  title: Text(
                    countries[idx],
                  ),
                  leading: Radio(
                    value: countries[idx],
                    groupValue: region,
                    onChanged: (value) {
                      top_screen.localSongs = [];
                      region = countries[idx];
                      top_screen.localFetched = false;
                      top_screen.localFetchFinished.value = false;
                      Hive.box('settings').put('region', region);
                      Navigator.pop(context);
                    },
                  ),
                  selected: region == countries[idx],
                  onTap: () {
                    top_screen.localSongs = [];
                    region = countries[idx];
                    top_screen.localFetchFinished.value = false;
                    Hive.box('settings').put('region', region);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        );
      },
    );
    return region;
  }
}
