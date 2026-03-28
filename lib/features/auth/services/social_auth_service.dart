import 'package:hote_v2/core/services/app_services.dart';

class SocialAuthService {
  SocialAuthService._();

  static Future<String?> signInWithGoogle() async {
    return AppServices.auth.signInWithGoogle();
  }

  static Future<String?> signInWithFacebook() async {
    return AppServices.auth.signInWithFacebook();
  }
}
