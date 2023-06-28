import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/data/repository/client.dart';
import '../../main.dart';
import '../common.dart';
import '../screens/about_screen.dart';
import '../screens/login_screen.dart';
import '../screens/server_details.dart';
import '../screens/servers_overview.dart';
import '../screens/settings_screen.dart';
import 'drawer.dart';
import 'links.dart';
import 'package:flutter_svg/flutter_svg.dart';

Stack customButtonStack(BuildContext context) {
  return Stack(
    children: [
      CustomPaint(
        painter: CustomShapeCurve(context),
      ),
      Container(
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.clear,
            color: Colors.white,
            size: 18,
          ),
        ),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF3E80FF),
        ),
      ),
    ],
  );
}

class DrawerDesktopMenu extends StatefulWidget {
  const DrawerDesktopMenu({Key? key}) : super(key: key);

  @override
  _DrawerDesktopMenuState createState() => _DrawerDesktopMenuState();
}

class _DrawerDesktopMenuState extends State<DrawerDesktopMenu> {
  @override
  Widget build(BuildContext context) {
    setState(() {});
    return drawerNodes(context);
  }
}

Widget drawerNodes(BuildContext context) {
  return Stack(
    children: [
      Row(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          child: Image.asset('assets/black_rocket.png'),
                          width: 45,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Watch Tower',
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
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
                                const SizedBox(width: 20),
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
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [nodesSideMenu(context)],
                        ),
                      ],
                    ),
                    ///InkWell(
                    ///  child: Padding(
                    ///    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                    ///    child: Row(
                    ///      mainAxisAlignment: MainAxisAlignment.start,
                    ///      children: [
                    ///        SizedBox(
                    ///          width: 20,
                    ///          child: Align(
                    ///            alignment: Alignment.centerLeft,
                    ///            child: SvgPicture.asset('assets/add_node.svg',
                    ///                color: Theme.of(context).brightness ==
                    ///                    Brightness.dark
                    ///                    ? Colors.white
                    ///                    : Colors.grey.shade700),
                    ///          ),
                    ///        ),
                    ///        const SizedBox(width: 15),
                    ///        Text(
                    ///          'Add node',
                    ///          style: GoogleFonts.montserrat(
                    ///              textStyle: const TextStyle(
                    ///                  fontWeight: FontWeight.w400, fontSize: 16)),
                    ///        ),
                    ///      ],
                    ///    ),
                    ///  ),
                    ///  onTap: () {},
                    ///),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset('assets/settings.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Settings',
                              style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w400, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset('assets/privacy.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'Privacy policy',
                              style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w400, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        openPrivacyPolicy();
                      },
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: SvgPicture.asset('assets/about.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              'About us',
                              style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w400, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            color: Theme.of(context).brightness == Brightness.dark
                ? kBackgroundColorDark
                : kBackgroundColorLight,
            width: 250,
            height: MediaQuery.of(context).size.height,
          ),
        ],
      ),
      Positioned(
        left: 238,
        height: 100,
        child: InkWell(
          child: Container(
            color: Colors.transparent,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Align(
                alignment: Alignment.topRight,
                child: customButtonStack(context),
              ),
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    ],
  );
}

Widget nodesSideMenu(BuildContext context) {
  List<Widget> nodesListSideMenu = [];
  if (nodesList.isEmpty) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.04);
  } else {
    for (int i = 0; i < nodesList.length; i++) {
      nodesListSideMenu.add(
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServersOverviewScreen(
                              clickedNode: nodesList[i],
                            )),
                    (route) => false);
                Scaffold.of(context).closeDrawer();
              },
              child: Text(
                '${nodesList[i].ticker}',
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18)),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                clearUserData();
                // clearTextControllers();
                timer?.cancel();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              },
              child: Container(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                  child: Text(
                    'Log out',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: Color(0xFF5690FF),
                ),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
      );
      nodesListSideMenu.add(SizedBox(height: MediaQuery.of(context).size.height * 0.01));
      for (int k = 0; k < nodesList[i].servers!.length; k++) {
        nodesListSideMenu.add(InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => ServerDetailsScreen(
                          clickedNode: nodesList[i],
                          uuid: nodesList[i].servers![k].uuid!,
                        )),
                (route) => false);
            Scaffold.of(context).closeDrawer();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7).copyWith(left: 15),
            child: Row(
              children: [
                SizedBox(
                  child: Image.asset('assets/server.png'),
                  width: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  '${nodesList[i].servers![k].name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 14),
                ),
              ],
            ),
          ),
        ));
      }
      if (i + 1 < nodesList.length) {
        nodesListSideMenu.add(const SizedBox(height: 20));
      }
    }
    Column nodes = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: nodesListSideMenu,
        ),
        const SizedBox(height: 20),
      ],
    );
    return nodes;
  }
}
