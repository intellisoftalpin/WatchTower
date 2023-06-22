import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common.dart';

class ServersNotAvailableScreenMobile extends StatelessWidget {
  const ServersNotAvailableScreenMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        SvgPicture.asset('assets/servers_not_available.svg', color: kLightBlue),
        const SizedBox(height: 20),
        Center(child: Text('Watch Tower services are temporary not available,\n try again later.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14),),
        ),
      ],
    );
  }
}


class ServersNotAvailableScreenDesktop extends StatelessWidget {
  const ServersNotAvailableScreenDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        SvgPicture.asset('assets/servers_not_available.svg', color: kLightBlue),
        const SizedBox(height: 20),
        Center(child: Text('Watch Tower services are temporary not available,\n try again later.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 14),),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }
}
