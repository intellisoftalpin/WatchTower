import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

bool isDrawerOpen = false;
ScreensMobile previousScreenMobile = ScreensMobile.unknown;

enum DeviceType { mobile, desktop }

enum FieldType { controller, username, password }

enum DesktopPage {
  addNode,
  settings,
  privacyPolicy,
  aboutUs,
  logOut,
  nodesOverview,
  serversOverview,
  serverDetails,
  unknown
}

enum ScreensMobile {
  start,
  login,
  nodesOverview,
  serversOverview,
  serverDetails,
  about,
  privacyPolicy,
  unknown
}

Color kBackgroundColorLight = Colors.white;
Color kBackgroundColorDark = const Color(0xFF131629);
Color kDarkCardColor = const Color(0xFF162143);
Color kDesktopCardColor = const Color(0xFF1C2039);
Color kDarkDividerColor = const Color(0xFF282C49);
Color kBlueColor = const Color(0xFF2972FE);
Color kBlueColorUpdateMode = const Color(0xFF3E81FF);
Color kLightBlue = const Color(0xFF548FFF);
Color kLightRed = const Color(0xFFFF5353);
Color kTimeUpdateBarDark = const Color(0xFFF4F4F8);
Color kTimeUpdateBarLight = const Color(0xFFCDCDCD);
Color kTimeUpdateBarNumberDark = const Color(0xFFA6A6A6);
Color kTimeUpdateBarNumberLight = const Color(0xFF595959);
//Color(0xFF1C2039)

Padding desktopHeader(BuildContext context, DesktopPage page,
    GlobalKey<ScaffoldState> scaffoldKey) {
  return Padding(
      padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02)
          .copyWith(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.045),
      child: Stack(
        children: [
          Row(
            children: [
              Stack(
                children: <Widget>[
                  Positioned(
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => {scaffoldKey.currentState?.openDrawer()},
                      ))
                ],
              ),
              const SizedBox(
                width: 25,
              ),
              SizedBox(
                child: Image.asset('assets/black_rocket_61X61.png'),
                width: 45,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Text(
                'Watch Tower',
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18)),
              ),
            ],
          ),
          page == DesktopPage.settings ? SizedBox(
            height: 45,
            child: Center(
              child: Text(
                'Settings',
                style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18)),
              ),
            ),
          ):
          page == DesktopPage.aboutUs
              ? SizedBox(
                height: 45,
                child: Center(
                  child: Text(
                      'About us',
                      style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 18)),
                  ),
                ),
              ): const SizedBox.shrink(),
        ],
      ));
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({Key? key}) : super(key: key);


  Widget errorMobile(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        SvgPicture.asset('assets/servers_not_available.svg', color: kLightBlue),
        const SizedBox(height: 20),
        Center(child: Text('Something went wrong,\n try again later.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14),),
        ),
      ],
    );
  }

  Widget errorDesktop(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        SvgPicture.asset('assets/servers_not_available.svg', color: kLightBlue),
        const SizedBox(height: 20),
        Center(child: Text('Something went wrong,\n try again later.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14),),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid || Platform.isIOS ? errorMobile(context) :
    errorDesktop(context);
  }
}

Container footer(BuildContext context) {
  return Container(
    child: Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.02),
      child: Column(
        children: [
          SizedBox(
              child: SvgPicture.asset('assets/white_rocket_desktop.svg'),
              height: MediaQuery.of(context).size.height * 0.06),
          SizedBox(height: MediaQuery.of(context).size.height * 0.003),
          Text('Watch Tower',
              style: GoogleFonts.montserrat(
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18))),
        ],
      ),
    ),
    width: double.infinity,
    color: Colors.black,
  );
}

ElevatedButton backScreenButton(BuildContext context,
    {required String text,
    double startWidth = 0,
    double endWidth = 0,
    required void Function() screen}) {
  return ElevatedButton(
    onPressed: screen,
    style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    child: Ink(
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color(0xFF3A7EFF),
            Color(0xFF5690FF),
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: startWidth),
            SvgPicture.asset('assets/ic_back_btn.svg', height: 16),
            const SizedBox(
              width: 20,
            ),
            Center(
              child: Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w100),
              ),
            ),
            SizedBox(width: endWidth),
          ],
        ),
      ),
    ),
  );
}

Text getStatusStyle(BuildContext context, String status,
    {double textSize = 14}) {
  if (status.contains('ok')) {
    return Text('Ok',
        style: GoogleFonts.montserrat(
            textStyle: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w400,
                fontSize: textSize)));
  } else if (status.contains('error')) {
    return Text('Error',
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w400,
              fontSize: textSize),
        ));
  } else if (status.contains('Warning')) {
    return Text('Warning',
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
            color: const Color(0xFFAB7100),
            fontWeight: FontWeight.w400,
            fontSize: textSize,
          ),
        ));
  } else if (status.contains('Failed')) {
    return Text('Failed',
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: textSize),
        ));
  } else {
    return Text('N/A',
        style: GoogleFonts.montserrat(
          textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: textSize),
        ));
  }
}

TextStyle st1 = const TextStyle(fontWeight: FontWeight.w400);
TextStyle st2 =
    const TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF5A5A5A));
