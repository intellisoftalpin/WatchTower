import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/data/repository/client.dart';
import 'package:tower/main.dart';
import 'package:tower/ui/common.dart';
import '../../data/models/node_model.dart';
import '../settings_manager.dart';
import '../widgets/drawer.dart';
import '../widgets/drawer_desktop.dart';
import 'login_screen.dart';
import 'servers_overview.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NodeOverviewScreen extends StatefulWidget {
  const NodeOverviewScreen({Key? key}) : super(key: key);

  @override
  State<NodeOverviewScreen> createState() => _NodeOverviewScreenState();
}

class _NodeOverviewScreenState extends State<NodeOverviewScreen>
    with WidgetsBindingObserver {
  Future<List<NodeGroupModel>>? _nodes;
  Future<dynamic>? serversOverview;
  Future<bool>? errorMessage;
  AppLifecycle isNodesOverviewScreenBackground = AppLifecycle.active;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  int timeAdd = 1;
  late Timer _timer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  Future<bool> errorMessageFuture() async {
    await Future.delayed(const Duration(seconds: 5));
    return true;
  }

  @override
  initState() {
    showNextUpdateTime = '-${updateSettingsTime.inSeconds - 1}s';
    previousScreenMobile = ScreensMobile.nodesOverview;
    manualUpdateTimer?.cancel();
    autoUpdateTimer?.cancel();
    timer?.cancel();
    errorMessage = errorMessageFuture();
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500),
        (Timer t) => checkTokenExpiration(context));

    WidgetsBinding.instance.addObserver(this);
    DateTime now = DateTime.now();
    lastUpdateTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _nodes = getNodes(context).whenComplete(() {
      for (int i = 0; i < nodesList.length; i++) {
        for (int k = 0; k < nodesList[i].servers!.length; k++) {
          serversOverview = getStatistics(
              nodesList[i].servers![k].uuid!, context, nodesList[i]);
        }
      }
    });

    ///next = now.add(updateSettingsTime);
    if (mode == UpdateMode.auto) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
            (Timer t) => timeBeforeAutoUpdate(),
      );
    } else if (mode == UpdateMode.manual) {
      showLastUpdateTime = '0s';
      enableRefreshIndicator = true;
      manualUpdateTimer =
          Timer.periodic(const Duration(seconds: 1), (Timer t) {
            timeLastAutoUpdate(manualUpdateTimer?.tick);
            setState(() {});
          });
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
        if (isDrawerOpen) {
          Navigator.of(context).pop();
          return false;
        } else {
          return true;
        }
      },
      child: RefreshIndicator(
        notificationPredicate:
            enableRefreshIndicator ? (_) => true : (_) => false,
        onRefresh: () async {
          showLastUpdateTime = '0s';
          setState(() {});
          _nodes = getNodes(context).whenComplete(() {
            for (int i = 0; i < nodesList.length; i++) {
              for (int k = 0; k < nodesList[i].servers!.length; k++) {
                serversOverview = getStatistics(
                    nodesList[i].servers![k].uuid!, context, nodesList[i]);
              }
            }
          });
          DateTime now = DateTime.now();
          lastUpdateTime =
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
          manualUpdateTimer?.cancel();
          manualUpdateTimer =
              Timer.periodic(const Duration(seconds: 1), (Timer t) {
            timeLastAutoUpdate(manualUpdateTimer?.tick);
            setState(() {});
          });
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF131629)
              : kBackgroundColorLight,
          onDrawerChanged: (isOpened) {
            isDrawerOpen = isOpened;
          },
          drawer: const DrawerMenu(),
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
            title: Text('Overview Nodes',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                )),

            ///actions: [
            ///  Padding(
            ///    padding: const EdgeInsets.only(right: 20),
            ///    child: SizedBox(
            ///      width: 34,
            ///      child: FloatingActionButton(
            ///        backgroundColor: const Color(0xFF5690FF),
            ///        child: const Icon(
            ///          Icons.add,
            ///          color: Colors.white,
            ///          size: 24,
            ///        ),
            ///        onPressed: () {},
            ///      ),
            ///    ),
            ///  ),
            ///],
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF131629)
                : kBackgroundColorLight,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06),
                  child: Stack(
                    children: [
                      Row(
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
                                  showNextUpdateTime =
                                      '-${updateSettingsTime.inSeconds - 1}s';
                                  timeAdd = 1;
                                  _timer = Timer.periodic(
                                    const Duration(seconds: 1),
                                    (Timer t) => timeBeforeAutoUpdate(),
                                  );
                                } else {
                                  box.write('mode', 'manual');
                                  showLastUpdateTime = '0s';
                                  _timer.cancel();
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                ),
                FutureBuilder<List<NodeGroupModel>>(
                  future: _nodes,
                  builder: (BuildContext context, AsyncSnapshot snapshotNodes) {
                    if (snapshotNodes.hasData) {
                      if (nodesList.isNotEmpty) {
                        return FutureBuilder(
                          future: serversOverview,
                          builder: (BuildContext context,
                              AsyncSnapshot snapshotStatistic) {
                            if (snapshotStatistic.hasData) {
                              if (serversList1.isNotEmpty) {
                                return nodeCardMobile(context, snapshotNodes);
                              } else {
                                return const Column(
                                  children: [
                                    Center(child: CircularProgressIndicator()),
                                  ],
                                );
                              }
                            } else {
                              return const Column(
                                children: [
                                  Center(child: CircularProgressIndicator()),
                                ],
                              );
                            }
                          },
                        );
                      } else {
                        return FutureBuilder(
                            future: errorMessage,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return const Column(
                                  children: [
                                    Center(child: CircularProgressIndicator()),
                                  ],
                                );
                              } else {
                                return const Column(
                                  children: [
                                    Center(child: CircularProgressIndicator()),
                                  ],
                                );
                              }
                            });
                      }
                    } else {
                      return const Column(
                        children: [
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column nodeCardMobile(BuildContext context, AsyncSnapshot snapshotNodes) {
    List<Widget> nodes = [];
    List<String?> _tickers = [];
    nodes.add(
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
    );
    for (var data in nodesList) {
      _tickers.add(data.ticker);
    }
    for (int i = 0; i < nodesList.length; i++) {
      nodes.add(
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02),
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServersOverviewScreen(
                            clickedNode: nodesList[i],
                          )),
                  (route) => false);
            },
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.02),
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_tickers[i]}',
                              //'${snapshotNodes.data[0].ticker}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                            ),
                            getStatusStyle(
                                context, '${nodesList[i].nodeStatus}',
                                textSize: 16),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                            offset: const Offset(
                              0.0,
                              6.0,
                            ),
                            blurRadius: 3.0,
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.02),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
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
                                    '39.51k',
                                    style: TextStyle(
                                        color: Colors.black.withOpacity(0.95),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    '29',
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
                              : Colors.white70,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    getServersMobile(i, context),
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
                    blurRadius: 4.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.grey.shade400,
                    offset: const Offset(0, 6.0),
                    blurRadius: 5.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    nodes.add(
      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
    );
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: nodes);
  }

  Widget getServersMobile(int i, BuildContext context) {
    List<Widget> servers = [];
    if (nodesList[i].servers!.isNotEmpty) {
      for (var data in nodesList[i].servers!) {
        String? name = data.name;
        String? type = data.type;
        String? status = data.serverStatus;
        servers.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                child: Image.asset('assets/server.png'),
                width: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                // '${nodesList[i].servers![k].name}',
                name ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                // '${nodesList[i].servers![k].type}',
                type ?? '',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w300),
              ),
              const Spacer(),
              getStatusStyle(context, status ?? '', textSize: 14),
              // getStatusStyle('${nodesList[i].servers![k].serverStatus}', textSize: 14),
            ],
          ),
        );
        servers.add(
          const SizedBox(
            height: 5,
          ),
        );
      }
    }
    return Stack(
      children: [
        Column(
          children: servers,
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.25,
          child: Container(
            width: 2,
            color: Theme.of(context).brightness == Brightness.dark
                ? kDarkDividerColor
                : Colors.white,
            height: 25 * (nodesList[i].servers!.length).toDouble(),
          ),
        ),
      ],
    );
  }

  Scaffold desktopMarkup(BuildContext context) {
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
        child: Column(
          children: [
            desktopHeader(context, DesktopPage.nodesOverview, scaffoldKey),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.025,
                  right: MediaQuery.of(context).size.width * 0.04),
              child: Row(
                children: [
                  InkWell(
                    child: Text('Overview Nodes',
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w300,
                                fontSize: 16))),
                    onTap: () {},
                  ),
                  const Spacer(),
                  Text(lastUpdateTime),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      if (enableRefreshIndicator == true) {
                        showLastUpdateTime = '0s';
                        setState(() {});
                        _nodes = getNodes(context).whenComplete(() {
                          for (int i = 0; i < nodesList.length; i++) {
                            for (int k = 0;
                                k < nodesList[i].servers!.length;
                                k++) {
                              serversOverview = getStatistics(
                                  nodesList[i].servers![k].uuid!,
                                  context,
                                  nodesList[i]);
                            }
                          }
                        });
                        DateTime now = DateTime.now();
                        lastUpdateTime =
                            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                        manualUpdateTimer?.cancel();
                        manualUpdateTimer = Timer.periodic(
                            const Duration(seconds: 1), (Timer t) {
                          timeLastAutoUpdate(manualUpdateTimer?.tick);
                          setState(() {});
                        });
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
                              borderRadius: BorderRadius.circular(10))
                          : BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.grey, Colors.grey],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                              borderRadius: BorderRadius.circular(10)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                        next = DateTime.now().add(updateSettingsTime);
                        showNextUpdateTime =
                            '-${updateSettingsTime.inSeconds - 1}s';
                        timeAdd = 1;
                        _timer = Timer.periodic(
                          const Duration(seconds: 1),
                          (Timer t) => timeBeforeAutoUpdate(),
                        );
                      } else {
                        box.write('mode', 'manual');
                        showLastUpdateTime = '0s';
                        _timer.cancel();
                        enableRefreshIndicator = true;
                        manualUpdateTimer = Timer.periodic(
                            const Duration(seconds: 1), (Timer t) {
                          timeLastAutoUpdate(manualUpdateTimer?.tick);
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
                                  color: kBlueColorUpdateMode, width: 3)
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
                                      'assets/refresh_btn_pause.svg')
                                ],
                              )
                            : SvgPicture.asset('assets/refresh_btn_load.svg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02),
              child: FutureBuilder<List<NodeGroupModel>>(
                future: _nodes,
                builder: (BuildContext context, AsyncSnapshot snapshotNodes) {
                  if (snapshotNodes.hasData) {
                    if (nodesList.isNotEmpty) {
                      return FutureBuilder(
                        future: serversOverview,
                        builder: (BuildContext context,
                            AsyncSnapshot snapshotStatistic) {
                          if (snapshotStatistic.hasData) {
                            if (serversList1.isNotEmpty) {
                              return nodeCardDesktop(context);
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      );
                    } else {
                      return FutureBuilder(
                          future: errorMessage,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return const CircularProgressIndicator();
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          });
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //       horizontal: MediaQuery.of(context).size.width * 0.02),
            //   child: FutureBuilder<List<NodeGroupModel>>(
            //     future: _nodes,
            //     builder: (BuildContext context, AsyncSnapshot snapshot) {
            //       if (snapshot.hasData) {
            //         return FutureBuilder(
            //           future: serversOverview,
            //           builder: (BuildContext context,
            //               AsyncSnapshot snapshotStatistic) {
            //             if (snapshotStatistic.connectionState ==
            //                     ConnectionState.done &&
            //                 snapshotStatistic.hasData &&
            //                 serversList1.isNotEmpty) {
            //
            //               return nodeCardDesktop(context);
            //             } else {
            //               return const Center(
            //                   child: CircularProgressIndicator());
            //             }
            //           },
            //         );
            //       } else {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //     },
            //   ),
            // ),
            const Spacer(),

            ///FloatingActionButton(
            ///  onPressed: () {},
            ///  backgroundColor: Theme.of(context).brightness == Brightness.dark
            ///      ? kDarkCardColor
            ///      : const Color(0xFFEEF6FF),
            ///  child: const Icon(
            ///    Icons.add,
            ///    color: Color(0xFF3E81FF),
            ///    size: 34,
            ///  ),
            ///),
            SizedBox(
                height: windowHeight < 600
                    ? MediaQuery.of(context).size.height * 0.02
                    : windowHeight < 700
                        ? MediaQuery.of(context).size.height * 0.03
                        : windowHeight < 800
                            ? MediaQuery.of(context).size.height * 0.1
                            : MediaQuery.of(context).size.height * 0.02),
            footer(context),
          ],
        ),
      )),
    );
  }

  Row nodeCardDesktop(BuildContext context) {
    List<Widget> nodes = [];
    List<String?> _tickers = [];
    for (var data in nodesList) {
      _tickers.add(data.ticker);
    }
    for (int i = 0; i < nodesList.length; i++) {
      nodes.add(
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ServersOverviewScreen(
                            clickedNode: nodesList[i],
                          )),
                  (route) => false);
            },
            child: Container(
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
                                MediaQuery.of(context).size.height * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tickers[i]}',
                                  style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          color: Colors.black, fontSize: 20)),
                                ),
                                getStatusStyle(
                                    context, '${nodesList[i].nodeStatus}',
                                    textSize: 16),
                              ],
                            ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: () {
                                clearUserData();
                                //clearTextControllers();
                                timer?.cancel();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                    (route) => false);
                              },
                              child: Container(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 7),
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  color: Color(0xFF5690FF),
                                ),
                              ),
                            ),
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.03),
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                              vertical: 10),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    getServersDesktop(i, context),
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
      if (i % 2 == 0 && i != 0) {
        nodes.add(SizedBox(width: MediaQuery.of(context).size.width * 0.02));
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodes,
    );
  }

  Widget getServersDesktop(int i, BuildContext context) {
    List<Widget> servers = [];
    //for (int k = 0; k < nodesList[i].servers!.length; k++) {
    for (int k = 0; k < serversList1.length; k++) {
      servers.add(Row(
        children: [
          SizedBox(
            child: Image.asset('assets/server.png'),
            width: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            '${serversList1[k].name}',
            //'${nodesList[i].servers![k].name}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            //'${nodesList[i].servers![k].type}',
            '${serversList1[k].type}',
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w300),
          ),
          const Spacer(),
          Row(
            children: [
              // getStatusStyle('${nodesList[i].servers![k].serverStatus}', textSize: 14),
              getStatusStyle(context, '${serversList1[k].serverStatus}',
                  textSize: 14),
            ],
          ),
        ],
      ));
      if (k + 1 < nodesList[i].servers!.length) {
        /*
        This check is necessary for the margin between a few of servers.
        */
        servers.add(
          const SizedBox(
            height: 15,
          ),
        );
      }
    }
    return Stack(
      children: [
        Column(
          children: servers,
        ),
      ],
    );
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

  Future<List<NodeGroupModel>>? getList() async {
    List<NodeGroupModel>? nodes = await getNodes(context);
    return nodes;
  }

  void updateData() {
    _nodes = getNodes(context).whenComplete(() {
      for (int i = 0; i < nodesList.length; i++) {
        for (int k = 0; k < nodesList[i].servers!.length; k++) {
          serversOverview = getStatistics(
              nodesList[i].servers![k].uuid!, context, nodesList[i]);
        }
      }
    });
    DateTime now = DateTime.now();
    lastUpdateTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    setState(() {});
  }

  void timeBeforeAutoUpdate() {
    timeAdd++;
    int timeDiff = timeAdd - updateSettingsTime.inSeconds;
    showNextUpdateTime = '${timeDiff}s';
    if (timeDiff == 0) {
      timeAdd = 1;
      showNextUpdateTime = '-${updateSettingsTime.inSeconds - 1}s';
      updateData();
    }
    setState(() {});

    ///DateTime now = DateTime.now();
    ///Duration difference = now.difference(next);
    ///if (difference.inSeconds >= 0) {
    ///  next = now.add(updateSettingsTime);
    ///}
    ///int commonTimeSeconds = difference.inSeconds;
    ///showNextUpdateTime = '${commonTimeSeconds}s';
    ///setState(() {});
    ///if (commonTimeSeconds == 0) {
    ///  updateData();
    ///}
  }

  @override
  void didChangePlatformBrightness() {
    platformBritness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    runApp(const InitialWidget());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('\n\n\n\n\n  PAUSED  \n\n\n\n');
      }
      _timer.cancel();
      isNodesOverviewScreenBackground = AppLifecycle.paused;
    } else if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('\n\n\n\n\n RESUMED \n\n\n\n\n');
      }
      isNodesOverviewScreenBackground = AppLifecycle.resumed;
      updateData();
      timeAdd = 0;
      showNextUpdateTime = '-${updateSettingsTime.inSeconds - 1}s';

      ///DateTime now = DateTime.now();
      ///next = now.add(updateSettingsTime);
      if (mode == UpdateMode.auto) {
        _timer = Timer.periodic(
          const Duration(seconds: 1),
          (Timer t) => timeBeforeAutoUpdate(),
        );
      }
    }
  }
}
