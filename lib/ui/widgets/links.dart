import 'package:url_launcher/url_launcher.dart';

const String rocketLink = 'adarocket.me';
const String privacyPolicyLink = 'https://adarocket.me/privacy/';

void openUrl(String urlString) async {
  final url = Uri.parse(urlString);

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

void openPrivacyPolicy() {
  openUrl(privacyPolicyLink);
}
