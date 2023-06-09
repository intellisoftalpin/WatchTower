import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/ui/screens/server_details.dart';
import '../../data/models/node_model.dart';
import '../../data/repository/client.dart';
import '../../main.dart';
import '../common.dart';
import '../settings_manager.dart';
import '../widgets/drawer.dart';
import '../widgets/drawer_desktop.dart';
import 'nodes_overview.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServersOverviewScreen extends StatefulWidget {
  final NodeGroupModel clickedNode;

  const ServersOverviewScreen({Key? key, required this.clickedNode})
      : super(key: key);

  @override
  State<ServersOverviewScreen> createState() => _ServersOverviewScreenState();
}

class _ServersOverviewScreenState extends State<ServersOverviewScreen>
    with WidgetsBindingObserver {
  Future<dynamic>? serversOverview;
  AppLifecycle isServersOverviewScreenBackground = AppLifecycle.active;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('\n\n\n\n\n  PAUSED  \n\n\n\n');
      }
      autoUpdateTimer?.cancel();
      isServersOverviewScreenBackground = AppLifecycle.paused;
    } else if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('\n\n\n\n\n RESUMED \n\n\n\n\n');
      }
      isServersOverviewScreenBackground = AppLifecycle.resumed;
      updateData();
      DateTime now = DateTime.now();
      next = now.add(updateSettingsTime);
      if (mode == UpdateMode.auto) {
        autoUpdateTimer = Timer.periodic(
            const Duration(milliseconds: 30),
            (Timer t) => {
                  timeBeforeAutoUpdate(),
                });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  initState() {
    previousScreenMobile = ScreensMobile.serversOverview;
    serversList1.clear();
    manualUpdateTimer?.cancel();
    autoUpdateTimer?.cancel();
    timer?.cancel();
    super.initState();
    if (mounted) {
      timer = Timer.periodic(const Duration(milliseconds: 10),
          (Timer t) => checkTokenExpiration(context));
    }
    WidgetsBinding.instance.addObserver(this);
    DateTime now = DateTime.now();
    lastUpdateTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    for (int i = 0; i < widget.clickedNode.servers!.length; i++) {
      serversOverview =
          getStatistics(widget.clickedNode.servers![i].uuid!, context);
    }

    next = now.add(updateSettingsTime);
    if (mounted) {
      if (mode == UpdateMode.auto) {
        autoUpdateTimer = Timer.periodic(
            const Duration(milliseconds: 30),
            (Timer t) => {
                  timeBeforeAutoUpdate(),
                });
      }

      if (mode == UpdateMode.manual) {
        showLastUpdateTime = '0s';
        enableRefreshIndicator = true;
        manualUpdateTimer =
            Timer.periodic(const Duration(seconds: 1), (Timer t) {
          timeLastAutoUpdate(manualUpdateTimer?.tick);
          setState(() {});
        });
      }
    }
  }

  void updateData() {
    serversList1.clear();
    for (int i = 0; i < widget.clickedNode.servers!.length; i++) {
      serversOverview =
          getStatistics(widget.clickedNode.servers![i].uuid!, context);
    }
    DateTime now = DateTime.now();
    lastUpdateTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    setState(() {});
  }

  void timeBeforeAutoUpdate() {
    DateTime now = DateTime.now();
    Duration difference = now.difference(next);
    if (difference.inSeconds >= 0) {
      next = now.add(updateSettingsTime);
    }
    int commonTimeSeconds = difference.inSeconds;
    if (commonTimeSeconds == 0) {
      updateData();
    }
    showNextUpdateTime = '${commonTimeSeconds}s';
    setState(() {});
  }

  void timeLastAutoUpdate(int? commonTimeSeconds) {
    int minutes = 0;
    int hours = 0;
    int seconds = 0;
    if (commonTimeSeconds != null) {
      if (commonTimeSeconds >= 60) {
        minutes = commonTimeSeconds ~/ 60;
        seconds = commonTimeSeconds - (minutes * 60);
        showLastUpdateTime = '${minutes}m ${seconds}s';
        if (minutes >= 60) {
          hours = minutes ~/ 60;
          showLastUpdateTime = '${hours}h';
        }
      } else {
        showLastUpdateTime = '${commonTimeSeconds}s';
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    windowHeight = MediaQuery
        .of(context)
        .size
        .height;
    windowWidth = MediaQuery
        .of(context)
        .size
        .width;
    if(kDebugMode){
      print('Window height: $windowHeight');
      print('Window width: $windowWidth');
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return mobileMarkup(context);
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

  Widget mobileMarkup(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NodeOverviewScreen()),
            (route) => false);
        return false;
      },
      child: RefreshIndicator(
        notificationPredicate:
            enableRefreshIndicator ? (_) => true : (_) => false,
        onRefresh: () async {
          serversList1.clear();
          showLastUpdateTime = '0s';
          setState(() {});
          for (int i = 0; i < widget.clickedNode.servers!.length; i++) {
            serversOverview =
                getStatistics(widget.clickedNode.servers![i].uuid!, context);
            DateTime now = DateTime.now();
            lastUpdateTime =
                "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
            manualUpdateTimer?.cancel();
            manualUpdateTimer =
                Timer.periodic(const Duration(seconds: 1), (Timer t) {
              timeLastAutoUpdate(manualUpdateTimer?.tick);
              setState(() {});
            });
          }
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? kBackgroundColorDark
              : kBackgroundColorLight,
          drawer: DrawerMenu(clickedNode: widget.clickedNode),
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Theme.of(context).brightness == Brightness.dark
                  ? kBackgroundColorDark
                  : kBackgroundColorLight,
            ),
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Builder(builder: (context) {
                return Container(
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
                      color: Color(0xFF5690FF),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF162143)
                          : const Color(0xFFE5ECFE),
                      borderRadius: BorderRadius.circular(10.0)),
                );
              }),
            ),
            title: Text('Overview Servers',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                )),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? kBackgroundColorDark
                : kBackgroundColorLight,
            elevation: 0,
          ),
          body: FutureBuilder(
            future: serversOverview,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (serversList1.isNotEmpty) {
                  if (serversList1.length ==
                      widget.clickedNode.servers!.length) {
                    return content();
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                  //return const ServersNotAvailableScreen();
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget content() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const SizedBox(height: double.infinity),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () {
                              mode == UpdateMode.manual
                                  ? mode = UpdateMode.auto
                                  : mode = UpdateMode.manual;
                              if (mode == UpdateMode.auto) {
                                box.write('mode', 'auto');
                                enableRefreshIndicator = false;
                                manualUpdateTimer?.cancel();
                                next = DateTime.now().add(updateSettingsTime);
                                autoUpdateTimer = Timer.periodic(
                                    const Duration(milliseconds: 30),
                                    (Timer t) => {
                                          timeBeforeAutoUpdate(),
                                        });
                              } else {
                                box.write('mode', 'manual');
                                showLastUpdateTime = '0s';
                                autoUpdateTimer?.cancel();
                                enableRefreshIndicator = true;
                                manualUpdateTimer = Timer.periodic(
                                    const Duration(seconds: 1), (Timer t) {
                                  timeLastAutoUpdate(manualUpdateTimer?.tick);
                                  setState(() {});
                                });
                              }
                              setState(() {});
                            },
                            child: mode == UpdateMode.auto
                                ? Container(
                                    width: 80,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: kBlueColorUpdateMode,
                                            width: 3),
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            showNextUpdateTime,
                                            style: TextStyle(
                                                color: kLightBlue,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          ),
                                          SvgPicture.asset(
                                              'assets/refresh_btn_pause.svg')
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 4),
                                        child: SvgPicture.asset(
                                            'assets/refresh_btn_load.svg')),
                                  )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(lastUpdateTime),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text('Ticker: ',
                    style: GoogleFonts.montserrat(
                      textStyle:
                          const TextStyle(color: Colors.grey, fontSize: 16),
                    )),
                const SizedBox(height: 5),
                //TODO: how to update the node ticker? Must we take it from the statistics?
                Text(
                  '${widget.clickedNode.ticker}',
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 15),
                Text('Pool: ',
                    style: GoogleFonts.montserrat(
                      textStyle:
                          const TextStyle(color: Colors.grey, fontSize: 16),
                    )),
                const SizedBox(height: 5),
                Text('23456789765445',
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500))),
                const SizedBox(height: 15),
                Text('Website: ',
                    style: GoogleFonts.montserrat(
                      textStyle:
                          const TextStyle(color: Colors.grey, fontSize: 16),
                    )),
                const SizedBox(height: 5),
                Text('blackrocket.space',
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500))),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02),
                  child: Container(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                          vertical: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Active Stake: ', style: st2),
                              const SizedBox(
                                height: 15,
                              ),
                              Text('Delegators: ', style: st2),
                              const SizedBox(
                                height: 15,
                              ),
                              Text('Minted blocks: ', style: st2),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '38.68k',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.95),
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                '18',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.95),
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                '7',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.95),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Divider(
                  height: 0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? kDarkDividerColor
                      : Colors.grey.shade200,
                  thickness: 2.5,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                serversList1.isNotEmpty
                    ? serversCardMobile(context)
                    : Container(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NodeOverviewScreen()),
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Ink(
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF3A7EFF),
                    Color(0xFF5690FF),
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  borderRadius: BorderRadius.circular(30)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.86,
                height: 55,
                alignment: Alignment.center,
                child: const Text(
                  'Back to overview',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w100),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column serversCardMobile(BuildContext context) {
    List<Widget> nodes = [];
    for (int i = 0; i < widget.clickedNode.servers!.length; i++) {
      nodes.add(
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02),
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServerDetailsScreen(
                      clickedNode: widget.clickedNode,
                      // uuid: widget.clickedNode.servers![i].uuid!,
                      uuid: serversList1[i].uuid!,
                    ),
                  ),
                  (route) => false);
            },
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.025),
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              child: Image.asset('assets/server.png'),
                              width: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${serversList1[i].name}',
                              // '${widget.clickedNode.servers![i].name}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '${serversList1[i].type}',
                              // '${widget.clickedNode.servers![i].type}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300),
                            ),
                            const Spacer(),
                            getStatusStyle(context, '${serversList1[i].serverStatus}',
                                textSize: 16)
                            // getStatusStyle('${widget.clickedNode.servers![i].serverStatus}', textSize: 16)
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    statuses(context, i),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kDarkCardColor
                    : const Color.fromRGBO(250, 250, 255, 0.8),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.grey.shade200,
                    offset: const Offset(
                      0.0,
                      0.0,
                    ),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ), //BoxShadow
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.grey.shade400,
                    offset: const Offset(0, 8.0),
                    blurRadius: 10.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: nodes,
    );
  }

  Padding statuses(BuildContext context, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Text(
                    // '${widget.clickedNode.servers![i].firstParam}: ',
                    '${serversList1[i].firstParam}: ',
                    style: st1,
                  ),
                  const Spacer(),
                  getStatusStyle(context, '${serversList1[i].firstParamStatus}'),
                  //  getStatusStyle('${widget.clickedNode.servers![i].firstParamStatus}'),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Text(
                    '${serversList1[i].secondParam}: ',
                    style: st1,
                  ),
                  const Spacer(),
                  getStatusStyle(context, '${serversList1[i].secondParamStatus}'),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Text(
                    '${serversList1[i].thirdParam}: ',
                    style: st1,
                  ),
                  const Spacer(),
                  getStatusStyle(context, '${serversList1[i].thirdParamStatus}'),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.35,
            child: Container(
              width: 2,
              color: Theme.of(context).brightness == Brightness.dark
                  ? kDarkDividerColor
                  : Colors.white,
              height: 70,
            ),
          ),
        ],
      ),
    );
  }

  Scaffold desktopMarkup(BuildContext context) {
    double widthBetweenContainers = windowWidth < 1000 ? MediaQuery.of(context).size.width * 0.1 :  windowWidth < 1200 ?  MediaQuery.of(context).size.width * 0.15 :  MediaQuery.of(context).size.width * 0.2;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundColorDark
          : kBackgroundColorLight,
      drawer: const DrawerDesktopMenu(),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Stack(
            children: [
              Column(
                children: [
                  desktopHeader(context, DesktopPage.serversOverview, scaffoldKey),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.005)
                                  .copyWith(left: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ticket',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 16))),
                                  Text('${widget.clickedNode.ticker}',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16))),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                          ),
                        ),
                        SizedBox(
                            width: widthBetweenContainers),
                        Expanded(
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.005)
                                  .copyWith(left: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pool',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 16))),
                                  Text('223456789101212342',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16))),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                          ),
                        ),
                        SizedBox(
                            width: widthBetweenContainers),
                        Expanded(
                          child: Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.005)
                                  .copyWith(left: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Website',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 16))),
                                  Text('blackrocket.space',
                                      style: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16))),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.035),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              child: Text('Overview Nodes',
                                  style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16))),
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NodeOverviewScreen()),
                                    (route) => false);
                              },
                            ),
                            Text('  /  ',
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16))),
                            InkWell(
                              child: Text('Overview Servers',
                                  style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16))),
                              onTap: () {},
                            ),
                          ],
                        ),
                        Text(lastUpdateTime),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.045),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (enableRefreshIndicator == true) {
                                    serversList1.clear();
                                    showLastUpdateTime = '0s';
                                    setState(() {});
                                    for (int i = 0;
                                        i < widget.clickedNode.servers!.length;
                                        i++) {
                                      serversOverview = getStatistics(
                                          widget.clickedNode.servers![i].uuid!,
                                          context);
                                    }
                                    DateTime now = DateTime.now();
                                    lastUpdateTime =
                                        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                                    manualUpdateTimer?.cancel();
                                    manualUpdateTimer = Timer.periodic(
                                        const Duration(seconds: 1), (Timer t) {
                                      timeLastAutoUpdate(
                                          manualUpdateTimer?.tick);
                                      setState(() {});
                                    });
                                    setState(() {});
                                  }
                                },
                                child: Ink(
                                  height: 40,
                                  width: 85,
                                  decoration: enableRefreshIndicator
                                      ? BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF3A7EFF),
                                                Color(0xFF5690FF),
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter),
                                          borderRadius:
                                              BorderRadius.circular(10))
                                      : BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Colors.grey,
                                                Colors.grey
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 9),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: const [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Center(
                                          child: Text(
                                            'Update',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              InkWell(
                                onTap: () {
                                  mode == UpdateMode.manual
                                      ? mode = UpdateMode.auto
                                      : mode = UpdateMode.manual;
                                  if (mode == UpdateMode.auto) {
                                    box.write('mode', 'auto');
                                    enableRefreshIndicator = false;
                                    manualUpdateTimer?.cancel();
                                    next =
                                        DateTime.now().add(updateSettingsTime);
                                    autoUpdateTimer = Timer.periodic(
                                        const Duration(milliseconds: 30),
                                        (Timer t) => {
                                              timeBeforeAutoUpdate(),
                                            });
                                  } else {
                                    box.write('mode', 'manual');
                                    showLastUpdateTime = '0s';
                                    autoUpdateTimer?.cancel();
                                    enableRefreshIndicator = true;
                                    manualUpdateTimer = Timer.periodic(
                                        const Duration(seconds: 1), (Timer t) {
                                      timeLastAutoUpdate(
                                          manualUpdateTimer?.tick);
                                      setState(() {});
                                    });
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  width: 80,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: mode == UpdateMode.auto
                                          ? Border.all(
                                              color: kBlueColorUpdateMode,
                                              width: 3)
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      color: mode == UpdateMode.auto
                                          ? Colors.white
                                          : const Color(0xFFE5ECFE)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    child: mode == UpdateMode.auto
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                showNextUpdateTime,
                                                style: TextStyle(
                                                    color: kLightBlue,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                              SvgPicture.asset(
                                                  'assets/refresh_btn_pause.svg'),
                                            ],
                                          )
                                        : SvgPicture.asset(
                                            'assets/refresh_btn_load.svg'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02),
                    child: FutureBuilder(
                      future: serversOverview,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (serversList1.isNotEmpty) {
                            if (serversList1.length ==
                                widget.clickedNode.servers!.length) {
                              return serversCardDesktop(context);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                            //return const ServersNotAvailableScreenDesktop();
                          }
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: MediaQuery.of(context).size.width * 0.02),
                  //   child: FutureBuilder(
                  //     future: serversOverview,
                  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //       if (snapshot.connectionState == ConnectionState.done &&
                  //           snapshot.hasData &&
                  //           serversList1.length ==
                  //               widget.clickedNode.servers!.length) {
                  //         // return serversList1.isNotEmpty ? serversCardDesktop(context): Container();
                  //         return serversCardDesktop(context);
                  //       } else {
                  //         return const Center(
                  //             child: CircularProgressIndicator());
                  //       }
                  //     },
                  //   ),
                  // ),
                  const Spacer(),
                  footer(context),
                ],
              ),
              // Positioned(
              //   bottom: MediaQuery.of(context).size.height * 0.15,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Padding(
              //         padding: EdgeInsets.symmetric(
              //             horizontal: MediaQuery.of(context).size.width * 0.02),
              //         child: SizedBox(
              //             child: backScreenButton(context,
              //                 text: 'Back to overview', screen: (){
              //                   Navigator.pushAndRemoveUntil(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (context) => const NodeOverviewScreen()),
              //                           (route) => false);
              //                 }),
              //             height: 45,),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Row serversCardDesktop(BuildContext context) {
    List<Widget> content = [];
    List<Widget> nodes = [];
    for (int i = 0; i < serversList1.length; i++) {
      nodes.add(
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServerDetailsScreen(
                      clickedNode: widget.clickedNode,
                      //uuid: widget.clickedNode.servers![i].uuid!,
                      uuid: serversList1[i].uuid!,
                    ),
                  ),
                  (route) => false);
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.27,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical:
                                MediaQuery.of(context).size.height * 0.012),
                        child: Row(
                          children: [
                            SizedBox(
                              child: Image.asset('assets/server.png'),
                              width: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            windowWidth < 1000 ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                   '${serversList1[i].name}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '${serversList1[i].type}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ): Row(children: [
                              Text(
                                '${serversList1[i].name}',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                '${serversList1[i].type}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                            ),
                            const Spacer(),
                            getStatusStyle(context, '${serversList1[i].serverStatus}',
                                textSize: 16),
                            // getStatusStyle(nodeStatus, textSize: 16),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.transparent
                                    : Colors.grey.shade400,
                            offset: const Offset(
                              0.0,
                              4.0,
                            ),
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          ),
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                            offset: const Offset(
                              0.0,
                              -0.0,
                            ),
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                    ),
                    statuses(context, i),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? kDesktopCardColor
                    : const Color(0xFFEFEFF3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
      if (i % 2 == 0) {
        nodes.add(SizedBox(width: MediaQuery.of(context).size.width * 0.02));
      }
    }
    content.add(
      Container(
        height: MediaQuery.of(context).size.height * 0.27,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.015,
              vertical:
              MediaQuery.of(context).size.height * 0.016),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Active Stake: ', style: st2),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Delegators: ', style: st2),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Minted blocks: ', style: st2),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    '38.68k',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '18',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '7',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey.shade300),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
    content.add(SizedBox(width: MediaQuery.of(context).size.width * 0.02));
    content.addAll(nodes);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content,
    );
  }
}
