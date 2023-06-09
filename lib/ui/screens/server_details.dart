import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/data/models/node_model.dart';
import 'package:tower/ui/screens/servers_overview.dart';
import 'package:tower/ui/settings_manager.dart';
import '../../data/repository/client.dart';
import '../../main.dart';
import '../common.dart';
import '../widgets/drawer.dart';
import '../widgets/drawer_desktop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'nodes_overview.dart';

class ServerDetailsScreen extends StatefulWidget {
  final NodeGroupModel clickedNode;
  final String uuid;

  const ServerDetailsScreen(
      {Key? key, required this.clickedNode, required this.uuid})
      : super(key: key);

  @override
  _ServerDetailsScreenState createState() => _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends State<ServerDetailsScreen>
    with WidgetsBindingObserver {
  Future<dynamic>? serversOverview;
  AppLifecycle isServerDetailsScreenBackground = AppLifecycle.active;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> blocksExpanded = List.filled(sortedDataBlocks.length, false);

  @override
  initState() {
    previousScreenMobile = ScreensMobile.serverDetails;
    manualUpdateTimer?.cancel();
    autoUpdateTimer?.cancel();
    serversList1.clear();
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

    serversOverview = getStatistics(widget.uuid, context);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateData() {
    serversList1.clear();
    serversOverview = getStatistics(widget.uuid, context);
    DateTime now = DateTime.now();
    lastUpdateTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
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

  Widget mobileMarkup(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ServersOverviewScreen(
                      clickedNode: widget.clickedNode,
                    )),
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
          serversOverview = getStatistics(widget.uuid, context);

          DateTime now = DateTime.now();
          lastUpdateTime =
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
          manualUpdateTimer?.cancel();
          manualUpdateTimer =
              Timer.periodic(const Duration(seconds: 1), (Timer t) {
            timeLastAutoUpdate(manualUpdateTimer?.tick);
            setState(() {});
          });
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF131629)
              : kBackgroundColorLight,
          drawer: DrawerMenu(clickedNode: widget.clickedNode, uuid: widget.uuid),
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
            title: Text('Server Details',
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
                ? const Color(0xFF131629)
                : kBackgroundColorLight,
            elevation: 0,
          ),
          body: FutureBuilder(
            future: serversOverview,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return stack();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  Widget stack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(lastUpdateTime),
                        ),
                      ],
                    ),
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
                  ],
                ),
                serversList1.isNotEmpty ? mobileContent() : Container(),
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
                      builder: (context) => ServersOverviewScreen(
                            clickedNode: widget.clickedNode,
                          )),
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
                  'Back to Servers',
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

  Column sortedDataMobile() {
    List<Widget> blocksList = [];
    Column parameters(int i) {
      List<Widget> list = [];
      for (int m = 0; m < sortedDataBlocks[i].data.length; m++) {
        String? title;

        /// TODO: why we need to do the status dynamic type?
        // String? status;
        dynamic status;
        sortedDataBlocks[i].data[m].entries.forEach((entry) {
          title = entry.key;
          status = entry.value;
        });
        list.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text('$status'),
            ],
          ),
        ));
      }
      return Column(
        children: list,
      );
    }

    for (int i = 0; i < sortedDataBlocks.length; i++) {
      Column dataBlock = Column(
        children: [
          Text('${sortedDataBlocks[i].blockName}',
              style: const TextStyle(
                  color: Color(0xFF4786FF), fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getStatusStyle(context, sortedDataBlocks[i].status),
              const SizedBox(width: 5),
              sortedDataBlocks[i].errors != null
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Error Code: ${sortedDataBlocks[i].errors?.errorCode}'),
                                Text(
                                    'Error Message: ${sortedDataBlocks[i].errors?.errorMessage}'),
                              ],
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.info_outline,
                        color: kTimeUpdateBarNumberLight,
                      ),
                      //TODO: This button uses the minimum splash radius, because it is impossible to make it bigger if padding is zero
                      splashRadius: 20.0,
                      splashColor: Colors.grey.shade200,
                      padding: const EdgeInsets.all(0),
                      constraints: const BoxConstraints(),
                    )
                  : const SizedBox.shrink()
            ],
          ),
          parameters(i),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        ],
      );
      blocksList.add(dataBlock);
    }
    return Column(children: blocksList);
  }

  Column mobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${serversList1.first.name}:',
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500))),
            getStatusStyle(context, '${serversList1.first.serverStatus}', textSize: 16),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Divider(
          height: 0,
          color: Theme.of(context).brightness == Brightness.dark
              ? kDarkDividerColor
              : Colors.grey.shade200,
          thickness: 2.5,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Text('Ticker: ',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            )),
        const SizedBox(height: 5),
        Text(
          '${serversList1.first.ticker}',
          style: GoogleFonts.montserrat(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Text('Node version: ',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(color: Colors.grey, fontSize: 16),
            )),
        const SizedBox(height: 5),
        Text(
          '${serversList1.first.nodeVersion}',
          style: GoogleFonts.montserrat(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Divider(
          height: 0,
          color: Theme.of(context).brightness == Brightness.dark
              ? kDarkDividerColor
              : Colors.grey.shade200,
          thickness: 2.5,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        sortedDataMobile(),
      ],
    );
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

  Scaffold desktopMarkup(BuildContext context) {
     windowWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundColorDark
          : kBackgroundColorLight,
      drawer: const DrawerDesktopMenu(),
      body: Stack(
        children: [
          Scrollbar(
            child: ListView(
              children: [
                desktopHeader(context, DesktopPage.serverDetails, scaffoldKey),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                FutureBuilder(
                  future: serversOverview,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return serversList1.isNotEmpty
                          ? desktopFutureBuilder()
                          : Container();
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
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
          //           child: backScreenButton(context, text: 'Back to servers', screen: (){
          //             Navigator.pushAndRemoveUntil(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => ServersOverviewScreen(
          //                     clickedNode: widget.clickedNode,
          //                   )),
          //                     (route) => false);
          //           }),
          //           height: 45,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget desktopFutureBuilder() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                        MediaQuery.of(context).size.height * 0.005)
                        .copyWith(left: 14, right: 14),
                    child: windowWidth > 1300 ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${serversList1.first.name}',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16))),
                        const Spacer(),
                        getStatusStyle(context, '${serversList1.first.serverStatus}',
                            textSize: 16),
                      ],
                    ):
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${serversList1.first.name}',
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: Theme.of(context).brightness ==
                                      Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16))),
                      getStatusStyle(context, '${serversList1.first.serverStatus}',
                          textSize: 16),
                    ],)
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Container(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                        MediaQuery.of(context).size.height * 0.005)
                        .copyWith(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ticket',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16))),
                        Text('${serversList1.first.ticker}',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16))),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Container(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                        MediaQuery.of(context).size.height * 0.005)
                        .copyWith(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Node version',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16))),
                        Text('${serversList1.first.nodeVersion}',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16))),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                child: Container(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                        MediaQuery.of(context).size.height * 0.005)
                        .copyWith(left: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16))),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.025),
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
                              builder: (context) => const NodeOverviewScreen()),
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
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ServersOverviewScreen(
                                    clickedNode: widget.clickedNode,
                                  )),
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
                    child: Text('Server Details',
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
                          showLastUpdateTime = '0s';
                          setState(() {});
                          serversOverview = getStatistics(widget.uuid, context);
                          DateTime now = DateTime.now();
                          lastUpdateTime =
                              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                          manualUpdateTimer?.cancel();
                          manualUpdateTimer = Timer.periodic(
                              const Duration(seconds: 1), (Timer t) {
                            timeLastAutoUpdate(manualUpdateTimer?.tick);
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
                                borderRadius: BorderRadius.circular(10))
                            : BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Colors.grey, Colors.grey],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter),
                                borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
            ],
          ),
        ),
        Column(
        children: [
           SizedBox(height: MediaQuery.of(context).size.height * 0.05),
           sortedDataDesktop()
            ],
          ),
        footer(context),
      ],
    );
  }

  Widget sortedDataDesktop() {
    List<Widget> blocksListLeftColumn = [];
    List<Widget> blocksListRightColumn = [];

    Column parameters(int i) {
      List<Widget> list = [];
      int amountOfParameters = sortedDataBlocks[i].data.length;
      if(blocksExpanded[i] == false){
        amountOfParameters > 5 ? amountOfParameters = 5 : amountOfParameters;
      }
      for (int m = 0; m < amountOfParameters; m++) {
        String? title;

        /// TODO: why we need to do the status dynamic type?
        // String? status;
        dynamic status;
        sortedDataBlocks[i].data[m].entries.forEach((entry) {
          title = entry.key;
          status = entry.value;
        });
        list.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text('$status'),
            ],
          ),
        ));
      }
      return Column(
        children: list,
      );
    }

    for (int i = 0; i < sortedDataBlocks.length; i++) {
      Column dataBlock = Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03),
              child: InkWell(
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
                              children: [
                                Text(
                                  '${sortedDataBlocks[i].blockName}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    getStatusStyle(context, sortedDataBlocks[i].status),
                                    const SizedBox(width: 5),
                                    sortedDataBlocks[i].errors != null
                                        ? IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          'Error Code: ${sortedDataBlocks[i].errors?.errorCode}'),
                                                      Text(
                                                          'Error Message: ${sortedDataBlocks[i].errors?.errorMessage}'),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.info_outline,
                                              color: kTimeUpdateBarNumberLight,
                                            ),
                                            //TODO: This button uses the minimum splash radius, because it is impossible to make it bigger if padding is zero
                                            splashRadius: 20.0,
                                            splashColor: Colors.grey.shade200,
                                            padding: const EdgeInsets.all(0),
                                            constraints: const BoxConstraints(),
                                          )
                                        : const SizedBox.shrink()
                                  ],
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
                        const SizedBox(height: 10),
                        SizedBox(
                            child: parameters(i),
                          height: blocksExpanded[i] == true ? sortedDataBlocks[i].data.length * 33.0 : 5 * 33.0,
                        ),
                        SizedBox(
                          height: 20,
                          child: sortedDataBlocks[i].data.length > 5 ? RotatedBox(
                            quarterTurns: blocksExpanded[i] == true ? 1 : 3,
                            child: SvgPicture.asset(
                                'assets/ic_back_btn.svg',
                                color: Theme
                                    .of(context)
                                    .brightness == Brightness.dark
                                    ? Colors.white
                                    :  Colors.black54),
                          ): const SizedBox.shrink(),
                        )

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
                onTap: sortedDataBlocks[i].data.length > 5 ? (){
                  blocksExpanded[i] = !blocksExpanded[i];
                  setState(() {});
                }: null,
              ),
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        ],
      );

      i % 2 == 0 ? blocksListLeftColumn.add(dataBlock): blocksListRightColumn.add(dataBlock);
    }
    return Row(
     crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Expanded(
         child:  Column(children: blocksListLeftColumn),
       ),
         Expanded(
              child:  Column(children: blocksListRightColumn),
     ),
   ],
 );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('\n\n\n\n\n  PAUSED  \n\n\n\n');
      }
      autoUpdateTimer?.cancel();
      isServerDetailsScreenBackground = AppLifecycle.paused;
    } else if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        print('\n\n\n\n\n RESUMED \n\n\n\n\n');
      }
      isServerDetailsScreenBackground = AppLifecycle.resumed;
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
}
