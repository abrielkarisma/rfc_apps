import 'package:rfc_apps/response/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthService {
  final String baseUrl = 'dotenv.env["BASE_URL]auth/google';

  Future<AuthResponse> googleLogin() async {
    final LoginUrl = Uri.parse("$baseUrl/login");
    if (await canLaunchUrl(LoginUrl)) {
      await launchUrl(LoginUrl, mode: LaunchMode.externalApplication);
      return AuthResponse(status: true, message: 'Login launched successfully');
    } else {
      throw 'Could not launch $LoginUrl';
    }
  }
}
