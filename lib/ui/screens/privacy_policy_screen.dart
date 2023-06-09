import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tower/ui/screens/server_details.dart';
import 'package:tower/ui/screens/servers_overview.dart';
import 'package:tower/ui/screens/start_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/models/node_model.dart';
import '../common.dart';
import '../widgets/links.dart';
import 'nodes_overview.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final NodeGroupModel? clickedNode;
  final String? uuid;
  const PrivacyPolicyScreen({ Key? key, this.clickedNode, this.uuid}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicyScreen> {

  @override
  Widget build(BuildContext context) {
    return setupViews(context, widget.clickedNode, widget.uuid);
  }

  Widget setupViews(BuildContext context, NodeGroupModel? clickedNode, String? uuid) {
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
                    .brightness == Brightness.dark
                    ? kBackgroundColorDark
                    : kBackgroundColorLight,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: kBlueColor),
              title: Text(
                'Privacy policy',
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Theme
                        .of(context)
                        .brightness == Brightness.dark ? Colors.white : Colors
                        .black,
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
              elevation: 0
          ),
          body: WebView(
              initialUrl: privacyPolicyLink,
              navigationDelegate: (NavigationRequest request) {
                final url = request.url;

                if(!url.contains(rocketLink) && request.isForMainFrame == true) {
                  openUrl(url);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              }
          )
      ),
    );
  }
}
