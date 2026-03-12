import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  SocialAuthService._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: <String>['email', 'profile'],
  );

  static Future<String?> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    return account?.email;
  }

  static Future<String?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: const <String>['email', 'public_profile'],
    );

    if (loginResult.status == LoginStatus.success) {
      final Map<String, dynamic> userData = await FacebookAuth.instance
          .getUserData(fields: 'name,email,picture.width(200)');
      final dynamic email = userData['email'];
      if (email is String && email.isNotEmpty) {
        return email;
      }
      final dynamic name = userData['name'];
      return name is String ? name : 'Facebook user';
    }

    if (loginResult.status == LoginStatus.cancelled) {
      return null;
    }

    throw Exception(loginResult.message ?? 'Facebook login failed');
  }
}
