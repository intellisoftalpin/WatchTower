import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/ui/common.dart';
import 'package:tower/ui/screens/login_screen.dart';
import 'package:tower/ui/widgets/drawer.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final Uri _url = Uri.parse('https://adarocket.me/install/');

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  @override
  void initState() {
    previousScreenMobile = ScreensMobile.start;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ?  kBackgroundColorDark : kBackgroundColorLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.1,
            horizontal: MediaQuery.of(context).size.width * 0.1),
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
                color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Stack(
            children: [
              SvgPicture.asset('assets/spot_group.svg'),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Watch new node',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                              color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.width * 0.15,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: const Color(0xFF5690FF),
                            foregroundColor: Colors.white,
                            child: const Icon(
                              Icons.add,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find out how to install',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 22,
                                color: Colors.grey.shade700),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        TextButton(
                          child: Text(
                            'adarocket.me/install/',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                color: Color(0xFF5690FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          onPressed: () {
                            _launchUrl();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mobileMarkup(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).brightness == Brightness.dark ?
          kBackgroundColorDark : kBackgroundColorLight,
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
                  color: Theme.of(context).brightness == Brightness.dark ?
                  const Color(0xFF162143) : const Color(0xFFE5ECFE),
                  borderRadius: BorderRadius.circular(10.0)),
            );
          }),
        ),
        title: Text(
          'Overview Nodes',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark ?
            Colors.white : Colors.black,
              fontSize: 18,
          ),)
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ?
        kBackgroundColorDark  : kBackgroundColorLight,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ?
      kBackgroundColorDark : kBackgroundColorLight,
      body: OrientationBuilder(
        builder: (context, orientation){
          return startScreenContent(context,
              orientation == Orientation.portrait);
        },
      ),
    );
  }

  Column startScreenContent(BuildContext context, bool isPortrait) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              'Watch new node',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark ?  Colors.white : Colors.grey.shade700),)
            ),
          ),
        ),
        Expanded(
          flex: isPortrait ? 3 : 4,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: isPortrait ? 300 : 180,
                child: Padding(
                  padding: isPortrait ? const EdgeInsets.all(110.0) : const EdgeInsets.all(50.0),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF5690FF),
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.add,
                      size: isPortrait ? 40: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                child: SvgPicture.asset('assets/login_decoration/spot_1.svg',
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.6,
              ),
              Positioned(
                child: SvgPicture.asset('assets/login_decoration/spot_2.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                top: MediaQuery.of(context).size.height * 0.08,
                left: MediaQuery.of(context).size.width * 0.4,
              ),
              Positioned(
                  child: SvgPicture.asset('assets/login_decoration/spot_3.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1D4493) : null),
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.15),
              Positioned(
                child: SvgPicture.asset('assets/login_decoration/spot_4.svg', color:  Theme.of(context).brightness == Brightness.dark ? const Color(0xFF214DA8) : null),
                top: MediaQuery.of(context).size.height * 0.13,
                right: MediaQuery.of(context).size.width * 0.2,
              ),
              Positioned(
                child: SvgPicture.asset('assets/login_decoration/spot_5.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                top: MediaQuery.of(context).size.height * 0.22,
                left: MediaQuery.of(context).size.width * 0.3,
              ),
              Positioned(
                  child: SvgPicture.asset('assets/login_decoration/spot_6.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.2),
              Positioned(
                  child: SvgPicture.asset('assets/login_decoration/spot_7.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.8),
              Positioned(
                  child: SvgPicture.asset('assets/login_decoration/spot_8.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: MediaQuery.of(context).size.width * 0.45),
            ],
          ),
        ),
        Expanded(
          flex: isPortrait ? 1 : 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Find out how to install',
                style: GoogleFonts.montserrat(textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark ?  Colors.white : Colors.grey.shade700
                ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                child: Text('adarocket.me/install/',
                    style: GoogleFonts.montserrat(textStyle: const TextStyle(
                      color: Color(0xFF5690FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      decoration: TextDecoration.underline,
                    ))),
                onPressed: () {
                  _launchUrl();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
