import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/main.dart';
import 'package:tower/ui/screens/server_details.dart';
import 'package:tower/ui/screens/servers_overview.dart';
import 'package:tower/ui/screens/start_screen.dart';
import '../../data/models/node_model.dart';
import '../../data/shared_preferences/shared_preferences_repository.dart';
import '../common.dart';
import 'dart:io';
import '../settings_manager.dart';
import '../widgets/drawer_desktop.dart';
import '../../utils/global_key_extension.dart';
import 'nodes_overview.dart';

enum TimeBarValue { tenSeconds, thirtySeconds, sixtySeconds }

class SettingsScreen extends StatefulWidget {
  final NodeGroupModel? clickedNode;
  final String? uuid;

  const SettingsScreen({Key? key, this.clickedNode, this.uuid})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TimeBarValue updateTimeValue;
  int popUpMenuValue = 1;
  final selectThemeKey = GlobalKey();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesRepository _preferences =
      SharedPreferencesRepository();

  @override
  void initState() {
    if (updateSettingsTime.inSeconds == 61) {
      updateTimeValue = TimeBarValue.sixtySeconds;
    } else if (updateSettingsTime.inSeconds == 31) {
      updateTimeValue = TimeBarValue.thirtySeconds;
    } else {
      updateTimeValue = TimeBarValue.tenSeconds;
    }

    //String? localStorageValue = box.read('themeMode');

    // if (localStorageValue == null) {
    //   popUpMenuValue = 1;
    // } else if (localStorageValue.contains('light')) {
    //   popUpMenuValue = 2;
    // } else if (localStorageValue.contains('dark')) {
    //   popUpMenuValue = 3;
    // } else {
    //   popUpMenuValue = 1;
    // }

    if (themeMode.contains('system')) {
      popUpMenuValue = 1;
    } else if (themeMode.contains('light')) {
      popUpMenuValue = 2;
    } else if (themeMode.contains('dark')) {
      popUpMenuValue = 3;
    } else {
      popUpMenuValue = 1;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return mobileMarkup(context, widget.clickedNode, widget.uuid);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return desktopMarkup(context);
      } else {
        return const ErrorMessage();
      }
    } catch (e) {
      /*------------------------------------------------------------------------
       for web it isn't possible to define platform.
       So it will an exception
       -------------------------------------------------------------------------
       */
      if (kDebugMode) {
        print(e);
      }
      return const ErrorMessage();
    }
  }

  Widget mobileMarkup(
      BuildContext context, NodeGroupModel? clickedNode, String? uuid) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          return previousScreenMobile == ScreensMobile.start
              ? const StartScreen()
              : previousScreenMobile == ScreensMobile.nodesOverview
                  ? const NodeOverviewScreen()
                  : previousScreenMobile == ScreensMobile.serversOverview
                      ? ServersOverviewScreen(clickedNode: clickedNode!)
                      : ServerDetailsScreen(
                          clickedNode: clickedNode!, uuid: uuid!);
        }), (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).brightness == Brightness.dark
                ? kBackgroundColorDark
                : kBackgroundColorLight,
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: kBlueColor),
          title: Text(
            'Settings',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return previousScreenMobile == ScreensMobile.start
                    ? const StartScreen()
                    : previousScreenMobile == ScreensMobile.nodesOverview
                        ? const NodeOverviewScreen()
                        : previousScreenMobile == ScreensMobile.serversOverview
                            ? ServersOverviewScreen(clickedNode: clickedNode!)
                            : ServerDetailsScreen(
                                clickedNode: clickedNode!, uuid: uuid!);
              }), (route) => false);
            },
            child: Platform.isAndroid
                ? const Icon(Icons.arrow_back_sharp)
                : const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? kBackgroundColorDark
              : kBackgroundColorLight,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08),
                  child: Row(
                    children: [
                      Text(
                        'Theme Mode (${popUpMenuValue == 1 ? 'system' : popUpMenuValue == 2 ? 'light' : 'dark'})',
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                          key: selectThemeKey,
                          splashRadius: 24,
                          iconSize: 34,
                          onPressed: () {
                            _showThemePopupMenu(selectThemeKey);
                            setState(() {});
                          },
                          icon: Icon(Icons.chevron_left,
                              size: 34,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : kTimeUpdateBarNumberLight)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Container(
                  height: 2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kDarkDividerColor
                      : Colors.grey.shade100),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08),
              child: Text(
                'Data updates (sec)',
                style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              alignment: Alignment.center,
              child: clickableStatusBar(0.08, 0.1, 0.25),
            )
          ],
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? kBackgroundColorDark
            : kBackgroundColorLight,
      ),
    );
  }

  Widget clickableStatusBar(double paddingValue, double progressNumberWidth1,
      double progressNumberWidth2) {
    Color colorTenSec = kBlueColorUpdateMode;
    Color colorThirtySec = Theme.of(context).brightness == Brightness.dark
        ? kTimeUpdateBarDark
        : kTimeUpdateBarLight;
    Color colorSixtySec = Theme.of(context).brightness == Brightness.dark
        ? kTimeUpdateBarDark
        : kTimeUpdateBarLight;

    if (updateTimeValue == TimeBarValue.tenSeconds) {
      colorTenSec = kBlueColorUpdateMode;
      colorThirtySec = Theme.of(context).brightness == Brightness.dark
          ? kTimeUpdateBarDark
          : kTimeUpdateBarLight;
      colorSixtySec = Theme.of(context).brightness == Brightness.dark
          ? kTimeUpdateBarDark
          : kTimeUpdateBarLight;
    } else if (updateTimeValue == TimeBarValue.thirtySeconds) {
      colorTenSec = kBlueColorUpdateMode;
      colorThirtySec = kBlueColorUpdateMode;
      colorSixtySec = Theme.of(context).brightness == Brightness.dark
          ? kTimeUpdateBarDark
          : kTimeUpdateBarLight;
    } else if (updateTimeValue == TimeBarValue.sixtySeconds) {
      colorTenSec = kBlueColorUpdateMode;
      colorThirtySec = kBlueColorUpdateMode;
      colorSixtySec = kBlueColorUpdateMode;
    }

    void pressTenSec() {
      updateTimeValue = TimeBarValue.tenSeconds;
      box.write('autoUpdateSec', 11);
      updateSettingsManager.switchSettingsTime(updateTimeValue);
      setState(() {});
    }

    void pressThirtySec() {
      updateTimeValue = TimeBarValue.thirtySeconds;
      box.write('autoUpdateSec', 31);
      updateSettingsManager.switchSettingsTime(updateTimeValue);
      setState(() {});
    }

    void pressSixtySec() {
      updateTimeValue = TimeBarValue.sixtySeconds;
      box.write('autoUpdateSec', 61);
      updateSettingsManager.switchSettingsTime(updateTimeValue);
      setState(() {});
    }

    double barWidth = MediaQuery.of(context).size.width - 60.0;
    Color firstLine = colorThirtySec;
    Color secondLine = colorSixtySec;
    double width = MediaQuery.of(context).size.width - 60.0;
    return Container(
      alignment: Alignment.center,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: Container(
                  height: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kTimeUpdateBarDark
                      : kTimeUpdateBarLight,
                ),
              ),
              SizedBox(
                  width: barWidth,
                  height: 15.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: barWidth * 0.35,
                        height: 15.0,
                        decoration: BoxDecoration(
                          color: firstLine,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                        ),
                      ),
                      Container(
                        width: barWidth * 0.65,
                        height: 15.0,
                        decoration: BoxDecoration(
                          color: secondLine,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      )
                    ],
                  )),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.16,
                    child: InkWell(
                      onTap: () {
                        pressTenSec();
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                updateTimeValue == TimeBarValue.tenSeconds
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                            child: Container(
                              height: 15,
                              color: colorTenSec,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.30,
                    child: InkWell(
                      onTap: () {
                        pressThirtySec();
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                updateTimeValue == TimeBarValue.thirtySeconds
                                    ? const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : BorderRadius.circular(0),
                            child: Container(height: 15, color: colorThirtySec),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.54,
                    child: InkWell(
                      onTap: () {
                        pressSixtySec();
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                updateTimeValue == TimeBarValue.sixtySeconds
                                    ? const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                            child: Container(height: 15, color: colorSixtySec),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
              color: Colors.red,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: width * 0.15,
                    child: InkWell(
                      child: Text(
                        '0',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? kTimeUpdateBarNumberDark
                                  : kTimeUpdateBarNumberLight),
                        ),
                      ),
                      onTap: () {
                        pressTenSec();
                      },
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: width * 0.3,
                      child: InkWell(
                        child: Text(
                          '10',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? kTimeUpdateBarNumberDark
                                    : kTimeUpdateBarNumberLight),
                          ),
                        ),
                        onTap: () {
                          pressTenSec();
                        },
                      )),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: width * 0.45,
                      child: InkWell(
                        child: Text(
                          '30',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? kTimeUpdateBarNumberDark
                                    : kTimeUpdateBarNumberLight),
                          ),
                        ),
                        onTap: () {
                          pressThirtySec();
                        },
                      )),
                  Container(
                      alignment: Alignment.centerRight,
                      width: width * 0.1,
                      child: InkWell(
                        child: Text(
                          '60',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? kTimeUpdateBarNumberDark
                                    : kTimeUpdateBarNumberLight),
                          ),
                        ),
                        onTap: () {
                          pressSixtySec();
                        },
                      )),
                ],
              )),
        ],
      ),
    );
  }

  Scaffold desktopMarkup(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundColorDark
          : kBackgroundColorLight,
      key: scaffoldKey,
      drawer: const DrawerDesktopMenu(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          desktopHeader(context, DesktopPage.settings, scaffoldKey),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.04),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal:
                    //       MediaQuery
                    //           .of(context)
                    //           .size
                    //           .width * 0.04),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         'Settings',
                    //         style: GoogleFonts.montserrat(
                    //           textStyle: const TextStyle(
                    //               fontWeight: FontWeight.w700,
                    //               fontSize: 18),
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: 28,
                    //         child: FloatingActionButton(
                    //           backgroundColor: const Color(0xFF5690FF),
                    //           foregroundColor: Colors.white,
                    //           onPressed: () {
                    //             Navigator.pop(context);
                    //           },
                    //           child: const Icon(
                    //             Icons.close,
                    //             size: 18,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 4),
                    // Container(
                    //   color:
                    //   Theme
                    //       .of(context)
                    //       .brightness == Brightness.dark
                    //       ? kDarkDividerColor
                    //       : const Color(0xFFEFEFF3),
                    //   height: 2,
                    //   width: double.infinity,
                    // ),
                    // SizedBox(
                    //     height:
                    //     MediaQuery
                    //         .of(context)
                    //         .size
                    //         .height * 0.04),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Theme Mode (${popUpMenuValue == 1 ? 'system' : popUpMenuValue == 2 ? 'light' : 'dark'})',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                  key: selectThemeKey,
                                  splashRadius: 24,
                                  iconSize: 34,
                                  onPressed: () {
                                    _showThemePopupMenu(selectThemeKey);
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.chevron_left,
                                      size: 34,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : kTimeUpdateBarNumberLight))
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? kDarkDividerColor
                            : const Color(0xFFEFEFF3),
                        height: 2,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60.0,
                      child: Column(
                        children: [
                          Align(
                            child: Text(
                              'Data updates (sec)',
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 15),
                          clickableStatusBar(0, 0.08, 0.18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kBackgroundColorDark
                      : Colors.white),
            ),
          ),
          footer(context),
        ],
      ),
    );
  }

  PopupMenuItem _buildPopupMenuItem(dynamic value, String text, bool enabled) {
    return PopupMenuItem(
      value: value,
      child: Text(text),
      enabled: enabled,
    );
  }

  void _showThemePopupMenu(GlobalKey selectThemeKey) async {
    var containerRect = selectThemeKey.globalPaintBounds ?? Rect.zero;
    //final mode = box.read("themeMode");
    final mode = themeMode;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(containerRect.left, containerRect.top,
          containerRect.right, containerRect.bottom),
      items: [
        _buildPopupMenuItem(1, "System", mode != "system"),
        _buildPopupMenuItem(2, "Light", mode != "light"),
        _buildPopupMenuItem(3, "Dark", mode != "dark"),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) {
        return;
      }

      popUpMenuValue = value;

      if (popUpMenuValue == 1) {
        themeManager.switchTheme(1);
        themeMode = 'system';
        // _preferences.setThemeMode('themeMode', 'system');
        //box.write('themeMode', 'system');
      } else if (popUpMenuValue == 2) {
        themeManager.switchTheme(2);
        themeMode = 'light';
        //_preferences.setThemeMode('themeMode', 'light');
        //box.write('themeMode', 'light');
      } else if (popUpMenuValue == 3) {
        themeManager.switchTheme(3);
        themeMode = 'dark';
        //_preferences.setThemeMode('themeMode', 'dark');
        //box.write('themeMode', 'dark');
      } else {
        themeManager.switchTheme(1);
        themeMode = 'system';
        // _preferences.setThemeMode('themeMode', 'system');
        // box.write('themeMode', 'system');
      }
    });
    _preferences.setThemeMode('themeMode', themeMode);
    setState(() {});
  }
}
