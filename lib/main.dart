//ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tower/ui/common.dart';
import 'package:tower/ui/screens/login_screen.dart';
import 'package:tower/ui/screens/nodes_overview.dart';
import 'package:tower/ui/screens/start_screen.dart';
import 'package:tower/ui/settings_manager.dart';
import 'package:tower/ui/theme/theme_constants.dart';
import 'package:tower/ui/theme/theme_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'data/repository/client.dart';
import 'data/shared_preferences/shared_preferences_repository.dart';

final box = GetStorage();
PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown');

ThemeManager themeManager = ThemeManager();
UpdateSettingsManager updateSettingsManager = UpdateSettingsManager();
TextEditingController passwordController = TextEditingController();
TextEditingController userController = TextEditingController();
TextEditingController serverController = TextEditingController();

enum AppLifecycle { resumed, paused, active, inactive }

Brightness? platformBritness;

enum UpdateMode { manual, auto }

Timer? manualUpdateTimer;
Timer? autoUpdateTimer;
UpdateMode mode = UpdateMode.auto;
String lastUpdateTime = '';
String showLastUpdateTime = '';
String showNextUpdateTime = '';
late DateTime next;
bool enableRefreshIndicator = false;
Timer? timer;
double windowWidth = 0.0;
double windowHeight = 0.0;
String themeMode = 'system';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();

  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   setWindowMinSize(const Size(1200, 900));
  // }

  await GetStorage.init();

  if(Platform.isWindows || Platform.isLinux || Platform.isMacOS){
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1000, 680),
      minimumSize: Size(850, 630),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const InitialWidget());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final SharedPreferencesRepository _preferences =
      SharedPreferencesRepository();
  bool? notShowStartScreen;

  void getSharedPreferences() async {
    bool? showStartScreenShPref =
        await _preferences.getNotShowStartScreen('startScreen');
    if (showStartScreenShPref == true) {
      notShowStartScreen = true;
    } else {
      notShowStartScreen = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  final Future<String> _countDown =
      Future<String>.delayed(const Duration(seconds: 3), () => '');

  @override
  void initState() {
    getSharedPreferences();
    // String? token =  box.read('token');
    //  if(token is String){
    //    getDataFromLocStorage();
    //  }
    super.initState();
    // getCredentialsFromTheLocStorage();
    if (box.read('mode').toString().contains('manual')) {
      mode = UpdateMode.manual;
    } else {
      mode = UpdateMode.auto;
    }
    if (box.read('autoUpdateSec') != null) {
      updateSettingsTime = Duration(seconds: box.read('autoUpdateSec'));
    }
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;
    if (kDebugMode) {
      print('Window height: $windowHeight');
      print('Window width: $windowWidth');
    }
    return defineInitialScreen(context);
  }

  Widget defineInitialScreen(BuildContext context) {
    //  String? token = box.read('token');
    if (kDebugMode) {
      print('TOKEN: $tokenJWT');
    }
    return Scaffold(
      body: FutureBuilder(
        future: _countDown,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (tokenJWT is String) {
              return const NodeOverviewScreen();
            } else if (notShowStartScreen == true) {
              return const LoginScreen();
            } else if (notShowStartScreen == false) {
              return const StartScreen();
            } else {
              return Scaffold(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF131629)
                    : kBackgroundColorLight,
                body: Center(child: CircularProgressIndicator()),
              );
            }
          } else {
            return Scaffold(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF131629)
                  : kBackgroundColorLight,
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class InitialWidget extends StatefulWidget {
  const InitialWidget({Key? key}) : super(key: key);

  @override
  _InitialWidgetState createState() => _InitialWidgetState();
}

class _InitialWidgetState extends State<InitialWidget>
    with WidgetsBindingObserver {
  final SharedPreferencesRepository _preferences =
      SharedPreferencesRepository();

  @override
  void initState() {
    getShPrefThemeMode();
    getShPrefJwtToken();
    WidgetsBinding.instance.addObserver(this);
    //String? token =  box.read('token');
    // if(token is String){
    //   getDataFromLocStorage();
    // }
    platformBritness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    themeManager.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    updateSettingsManager.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    platformBritness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    runApp(InitialWidget());
  }

  void getShPrefThemeMode() async {
    String? themeModeShPref = await _preferences.getThemeMode('themeMode');
    themeModeShPref != null ? themeMode = themeModeShPref : 'system';
    if (mounted) {
      setState(() {});
    }
  }

  void getShPrefJwtToken() async {
    tokenJWT = await _preferences.getJwtToken('token');
    if (tokenJWT is String) {
      getDataFromLocStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData? theme;
    if (themeMode.contains('system')) {
      theme = platformBritness == Brightness.dark ? darkTheme : lightTheme;
    } else if (themeMode.contains('light')) {
      theme = lightTheme;
    } else if (themeMode.contains('dark')) {
      theme = darkTheme;
    }
    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeManager.theme,
      debugShowCheckedModeBanner: false,
      home: const App(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    themeManager.removeListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    updateSettingsManager.removeListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.dispose();
  }
}

// void getCredentialsFromTheLocStorage(){
//     if(box.read('isTokenExpired') == true){
//       if(box.read('server') != null && box.read('username') != null){
//         userController.text = box.read('username');
//         serverController.text = box.read('server');
//       }
//   }
// }

String _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');
  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string');
  }
  return utf8.decode(base64Url.decode(output));
}

void checkTokenExpiration(BuildContext context) {
  //String? token = box.read('token');
  if (tokenJWT != null) {
    //if(tokenJWT!.length > 2) {
    DateTime currentDateTime = DateTime.now();
    // if(kDebugMode){
    //   print('currentDateTime $currentDateTime');
    //   print('token : $token');
    // }
    List<String> listTokenParts = tokenJWT!.split('.');
    String payloadPart = listTokenParts[1];
    String utf8Payload = _decodeBase64(payloadPart);
    dynamic utf8PayloadJsonDecode = jsonDecode(utf8Payload);
    DateTime tokenExpTime = DateTime.fromMillisecondsSinceEpoch(
        utf8PayloadJsonDecode["exp"] * 1000);
    // if(kDebugMode){
    //   print('timezone token time: ${tokenExpTime.timeZoneName}');
    //   print('timezone current time: ${currentDateTime.timeZoneName}');
    // }
    if (currentDateTime.compareTo(tokenExpTime) < 0) {
      // if(kDebugMode){
      //   print("currentDateTime is before tokenExpTime");
      // }
    }
    if (currentDateTime.compareTo(tokenExpTime) > 0 ||
        currentDateTime.compareTo(tokenExpTime) == 0) {
      // if(kDebugMode){
      //   print("currentDateTime is after tokenExpTime");
      // }
      timer?.cancel();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
      box.write('isTokenExpired', true);
      clearUserData();
    }
    //}
  }
}
