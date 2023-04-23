import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:incognito_music/Helpers/config.dart';
import 'package:incognito_music/Helpers/countrycodes.dart';
import 'package:incognito_music/Helpers/logging.dart';
import 'package:incognito_music/Screen/Home/home.dart';
import 'package:incognito_music/Screen/LocalMusic/downloaded_songs.dart';
import 'package:incognito_music/Screen/Settings/setting.dart';
import 'package:incognito_music/Screen/login/auth.dart';
import 'package:incognito_music/Screen/login/pref.dart';
import 'package:incognito_music/Services/audio_service.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'Helpers/route_handler.dart';
import 'Screen/Player/audioplayer.dart';
import 'Theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;

  await Hive.initFlutter();
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('stats');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  await openHiveBox('ytlinkcache', limit: true);
  // if (Platform.isAndroid) {
  //   setOptimalDisplayMode();
  // }
  await startService();
  runApp(const MyApp());
}

Future<void> setOptimalDisplayMode() async {
  await FlutterDisplayMode.setHighRefreshRate();
}

Future<void> startService() async {
  await initializeLogging();
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.hoangminhtai.mobile_project.channel.audio',
      androidNotificationChannelName: 'Incognito Music',
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: false,
      // Hive.box('settings').get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    Logger.root.severe('Failed to open $boxName Box', error, stackTrace);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/BlackHole/$boxName.hive');
      lockFile = File('$dirPath/BlackHole/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final String systemLangCode = Platform.localeName.substring(0, 2);
    if (ConstantCodes.languageCodes.values.contains(systemLangCode)) {
      _locale = Locale(systemLangCode);
    } else {
      final String lang =
          Hive.box('setting').get('lang', defaultValue: 'English') as String;
      _locale = Locale(ConstantCodes.languageCodes[lang] ?? 'en');
    }

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
  }

void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget initialFuntion() {
    return Hive.box('settings').get('userId') != null
        ? const HomePage() /*DownloadedSongs()*/
        : const AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor:
          AppTheme.themeMode == ThemeMode.dark ? Colors.black38 : Colors.white,
      statusBarBrightness: AppTheme.themeMode == ThemeMode.dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
          ? Brightness.light
          : Brightness.dark,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    return MaterialApp(
        title: 'Incognito Music',
        restorationScopeId: 'incognito_music',
        themeMode: AppTheme.themeMode,
        theme: AppTheme.lightTheme(context: context),
        darkTheme: AppTheme.darkTheme(context: context),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: ConstantCodes.languageCodes.entries
            .map((e) => Locale(e.value, ''))
            .toList(),
        navigatorKey: navigatorKey,
        //contain all link to direction
        routes: {
          '/': (context) => initialFuntion(),
          '/pref': (context) => const PrefScreen(),
          '/setting': (context) => const SettingPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/player') {
            return PageRouteBuilder(
                opaque: false, pageBuilder: (_, __, ___) => const PlayScreen());
          } else {
            return HandleRoute.handleRoute(settings.name);
          }
        });
  }
}
