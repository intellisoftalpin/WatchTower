import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/ui/screens/server_details.dart';
import 'package:tower/ui/screens/servers_overview.dart';
import 'package:tower/ui/screens/start_screen.dart';
import 'package:tower/ui/widgets/drawer_desktop.dart';
import 'dart:io';
import '../../data/models/node_model.dart';
import '../../main.dart';
import '../common.dart';
import '../screens/privacy_policy_screen.dart';
import '../widgets/links.dart';
import 'nodes_overview.dart';

class AboutScreen extends StatefulWidget {
  final NodeGroupModel? clickedNode;
  final String? uuid;
  const AboutScreen({Key? key, this.clickedNode, this.uuid}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {

  var scaffoldKey = GlobalKey<ScaffoldState>();


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

  Widget mobileMarkup(BuildContext context, NodeGroupModel? clickedNode, String? uuid) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) {
              return previousScreenMobile == ScreensMobile.start ? const StartScreen() :
              previousScreenMobile == ScreensMobile.nodesOverview ? const NodeOverviewScreen() :
              previousScreenMobile == ScreensMobile.serversOverview ? ServersOverviewScreen(clickedNode: clickedNode!) :
              ServerDetailsScreen(clickedNode: clickedNode!, uuid: uuid!);
            }), (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .brightness == Brightness.dark
            ? kBackgroundColorDark
            : kBackgroundColorLight,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme
                .of(context)
                .brightness == Brightness.dark ?
            kBackgroundColorDark : kBackgroundColorLight,
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: kBlueColor),
          title: Text(
            'About us',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return previousScreenMobile == ScreensMobile.start ? const StartScreen() :
                    previousScreenMobile == ScreensMobile.nodesOverview ? const NodeOverviewScreen() :
                    previousScreenMobile == ScreensMobile.serversOverview ? ServersOverviewScreen(clickedNode: clickedNode!) :
                    ServerDetailsScreen(clickedNode: clickedNode!, uuid: uuid!);
                  }), (route) => false);
            },
            child: Platform.isAndroid ? const Icon(Icons.arrow_back_sharp) : const Icon(Icons.arrow_back_ios),
          ),
          backgroundColor: Theme
              .of(context)
              .brightness == Brightness.dark
              ? kBackgroundColorDark
              : kBackgroundColorLight,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery
                              .of(context)
                              .size
                              .width * 0.38)
                          .copyWith(
                          top: MediaQuery
                              .of(context)
                              .size
                              .height * 0.05),
                      child: Image.asset('assets/black_rocket.png'),
                    ),
                    width: double.infinity,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.4,
                  ),
                  Positioned(
                    child: SvgPicture.asset('assets/login_decoration/spot_1.svg',
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark
                            ? const Color(0xFF172954)
                            : null),
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05,
                    left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.6,
                  ),
                  Positioned(
                    child: SvgPicture.asset('assets/login_decoration/spot_2.svg',
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark
                            ? const Color(0xFF172954)
                            : null),
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.08,
                    left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.4,
                  ),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_3.svg',
                          color: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? const Color(0xFF1D4493)
                              : null),
                      top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.15,
                      left: MediaQuery
                          .of(context)
                          .size
                          .width * 0.15),
                  Positioned(
                    child: SvgPicture.asset('assets/login_decoration/spot_4.svg',
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark
                            ? const Color(0xFF214DA8)
                            : null),
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.13,
                    right: MediaQuery
                        .of(context)
                        .size
                        .width * 0.2,
                  ),
                  Positioned(
                    child: SvgPicture.asset('assets/login_decoration/spot_5.svg',
                        color: Theme
                            .of(context)
                            .brightness == Brightness.dark
                            ? const Color(0xFF172954)
                            : null),
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.22,
                    left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3,
                  ),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_6.svg',
                          color: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? const Color(0xFF172954)
                              : null),
                      top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.3,
                      left: MediaQuery
                          .of(context)
                          .size
                          .width * 0.2),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_7.svg',
                          color: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? const Color(0xFF172954)
                              : null),
                      top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.3,
                      left: MediaQuery
                          .of(context)
                          .size
                          .width * 0.8),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_8.svg',
                          color: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? const Color(0xFF172954)
                              : null),
                      top: MediaQuery
                          .of(context)
                          .size
                          .height * 0.35,
                      left: MediaQuery
                          .of(context)
                          .size
                          .width * 0.45),
                ],
              ),
              Text(
                'Watch Tower',
                style: GoogleFonts.montserrat(
                  textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'v ${packageInfo.version}',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: Theme.of(context).brightness ==
                              Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'build ${packageInfo.buildNumber}',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: Theme.of(context).brightness ==
                              Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(clickedNode: clickedNode, uuid: uuid)),
                    );
                  } else {
                    openPrivacyPolicy();
                  }
                },
                child: Text('Privacy policy',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          color: Theme
                              .of(context)
                              .brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w300,
                          fontSize: 14),
                    )),


              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold desktopMarkup(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme
          .of(context)
          .brightness ==
          Brightness.dark
          ? kBackgroundColorDark : kBackgroundColorLight,
      drawer: const DrawerDesktopMenu(),
      body: Column(
        children: [
          desktopHeader(context, DesktopPage.aboutUs, scaffoldKey),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery
                .of(context)
                .size
                .width * 0.1, vertical: MediaQuery
                .of(context)
                .size
                .height * 0.05),
            child: Container(
              decoration: BoxDecoration(
                color: kBackgroundColorLight,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Theme
                        .of(context)
                        .brightness == Brightness.dark
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(
                        0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: SvgPicture.asset(
                        'assets/about_decoration/about_spot_decoration_2.svg'),),
                  Positioned(
                    right: 0,
                    child: SvgPicture.asset(
                        'assets/about_decoration/about_spot_decoration.svg'),),
                  Positioned(
                    bottom: 0,
                    left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3,
                    child: SvgPicture.asset(
                        'assets/about_decoration/about_spot_decoration_3.svg'),),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.05,
                        right: MediaQuery
                            .of(context)
                            .size
                            .width * 0.15,
                        bottom: MediaQuery
                            .of(context)
                            .size
                            .height * 0.05,
                        top: MediaQuery
                            .of(context)
                            .size
                            .height * 0.07),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/about_us_page.svg', height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.4),
                            Column(
                              children: [
                                Image.asset(
                                  'assets/rocket_512X512.png',
                                  width: 100,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Watch Tower',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18), color: Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'v ${packageInfo.version}',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color: Theme.of(context).brightness ==
                                                Brightness.dark
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'build ${packageInfo.buildNumber}',
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            color: Theme.of(context).brightness ==
                                                Brightness.dark
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.03,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
         const Spacer(),
          footer(context)
        ],
      ),
    );
  }
}
