import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/data/repository/client.dart';
import '../../data/models/node_model.dart';
import '../../main.dart';
import '../common.dart';
import '../screens/about_screen.dart';
import '../screens/login_screen.dart';
import '../screens/server_details.dart';
import '../screens/servers_overview.dart';
import '../screens/settings_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../widgets/links.dart';

Widget drawer(BuildContext context) {
  return Stack(
    children: [
      Row(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 40),
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
                        children: [
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              SvgPicture.asset('assets/add_node.svg',
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade700),
                              const SizedBox(width: 15),
                              Text('Add node',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const SettingsScreen();
                              }));
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/settings.svg',
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                                const SizedBox(width: 15),
                                Text(
                                  'Settings',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: (){
                              if (Platform.isAndroid || Platform.isIOS) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const PrivacyPolicyScreen()),
                                );
                              } else {
                                openPrivacyPolicy();
                              }
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/privacy.svg',
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                                const SizedBox(width: 15),
                                Text('Privacy policy',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return const AboutScreen();
                              }));
                            },
                            child: Row(
                              children: [
                                SvgPicture.asset('assets/about.svg',
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                                const SizedBox(width: 15),
                                Text('About',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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
        child: GestureDetector(
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

class DrawerMenu extends StatefulWidget {
  final NodeGroupModel? clickedNode;
  final String? uuid;
  const DrawerMenu({Key? key, this.clickedNode, this.uuid}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    setState(() {});
    return drawerNodes(context, widget.clickedNode, widget.uuid);
  }
}

Widget drawerNodes(BuildContext context, NodeGroupModel? clickedNode, String? uuid) {
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
                          children: [
                            nodesSideMenu(context),
                            Row(
                              children: [
                                SvgPicture.asset('assets/add_node.svg',
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.grey.shade700),
                                const SizedBox(width: 15),
                                Text('Add node',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return SettingsScreen(clickedNode: clickedNode, uuid: uuid);
                                }));
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/settings.svg',
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey.shade700),
                                  const SizedBox(width: 15),
                                  Text(
                                    'Settings',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: (){
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
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/privacy.svg',
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey.shade700),
                                  const SizedBox(width: 15),
                                  Text('Privacy policy',
                                      style: GoogleFonts.montserrat(
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return AboutScreen(clickedNode: clickedNode, uuid: uuid);
                                }));
                              },
                              child: Row(
                                children: [
                                  SvgPicture.asset('assets/about.svg',
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey.shade700),
                                  const SizedBox(width: 15),
                                  Text(
                                    'About',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                          ],
                        ),
                      ],
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
        child: GestureDetector(
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
            GestureDetector(
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
            GestureDetector(
              onTap: () {
                clearUserData();
               // clearTextControllers();
                timer?.cancel();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      nodesListSideMenu
          .add(SizedBox(height: MediaQuery.of(context).size.height * 0.01));
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

class CustomShapeCurve extends CustomPainter {

  final BuildContext context;
  CustomShapeCurve(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Theme.of(context).brightness == Brightness.dark ? Colors.black :  Colors.grey.shade400;
    paint.style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(12, -3);
    path.arcToPoint(const Offset(12, 29),
        radius: const Radius.circular(15), clockwise: false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
