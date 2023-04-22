import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:incognito_music/CustomWidgets/gradient_containers.dart';
import 'package:incognito_music/CustomWidgets/popup.dart';
import 'package:incognito_music/CustomWidgets/snack_bar.dart';
import 'package:incognito_music/CustomWidgets/textinput_dialog.dart';
import 'package:incognito_music/Helpers/config.dart';
import 'package:incognito_music/Services/nav.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
                    visible: theme == 'Custom',
                  )
                ],
              )),
            )
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
