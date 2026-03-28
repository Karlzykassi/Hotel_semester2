import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hote_v2/core/services/app_backend.dart';
import 'package:hote_v2/core/services/app_rest_api.dart';
import 'package:hote_v2/data/mock/mock_backend_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthActionResult {
  const AuthActionResult({
    required this.identity,
    this.requiresEmailConfirmation = false,
  });

  final String identity;
  final bool requiresEmailConfirmation;
}

class AuthRepository {
  AuthRepository();

  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: <String>['email', 'profile'],
  );

  SupabaseClient? get _client => AppBackend.client;

  bool get hasActiveSession {
    final SupabaseClient? client = _client;
    if (client == null) {
      return MockBackendStore.isSignedIn;
    }
    return client.auth.currentSession != null || MockBackendStore.isSignedIn;
  }

  User? get currentUser => AppBackend.currentUser;

  String get greetingName {
    final User? user = currentUser;
    if (user == null) {
      return MockBackendStore.profile.firstName;
    }

    final dynamic fullName = user.userMetadata?['full_name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim().split(RegExp(r'\s+')).first;
    }

    final String email = user.email ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'Guest';
  }

  Future<void> restoreLocalSessionContext() async {
    final SupabaseClient? client = _client;
    if (client == null) {
      return;
    }

    final User? user = client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _syncLocalSession(user);
  }

  Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const AuthException('Email and password are required.');
    }

    final SupabaseClient? client = _client;
    if (client == null) {
      await MockBackendStore.signInWithEmail(
        email: email.trim(),
        password: password,
      );
      return AuthActionResult(identity: email.trim());
    }

    final AuthResponse response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (response.user != null) {
      await _syncLocalSession(response.user!);
    }
    return AuthActionResult(
      identity: response.user?.email ?? email.trim(),
    );
  }

  Future<AuthActionResult> signUpWithEmail({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        phone.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw const AuthException('All registration fields are required.');
    }

    final SupabaseClient? client = _client;
    if (client == null) {
      await MockBackendStore.registerAccount(
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        password: password,
      );
      return AuthActionResult(identity: email.trim());
    }

    final AuthResponse response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, dynamic>{
        'full_name': name.trim(),
        'phone': phone.trim(),
      },
    );

    if (response.user != null && response.session != null) {
      await AppRestApi.insertRows(
        'profiles',
        body: <String, dynamic>{
          'id': response.user!.id,
          'full_name': name.trim(),
          'phone': phone.trim(),
        },
        queryParameters: <String, dynamic>{'on_conflict': 'id'},
        requiresAuth: true,
        upsert: true,
      );
      await _syncLocalSession(response.user!);
    }

    return AuthActionResult(
      identity: response.user?.email ?? email.trim(),
      requiresEmailConfirmation: response.session == null,
    );
  }

  Future<String?> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      return null;
    }

    final SupabaseClient? client = _client;
    if (client == null) {
      await MockBackendStore.signIn(
        email: account.email,
        displayName: account.displayName,
      );
      return account.displayName ?? account.email;
    }

    final GoogleSignInAuthentication authentication =
        await account.authentication;
    final String? idToken = authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google sign-in did not return an ID token.');
    }

    await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authentication.accessToken,
    );
    final User? user = client.auth.currentUser;
    if (user != null) {
      await _syncLocalSession(user);
    }

    return account.displayName ?? account.email;
  }

  Future<String?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: const <String>['email', 'public_profile'],
    );

    if (loginResult.status == LoginStatus.cancelled) {
      return null;
    }

    if (loginResult.status != LoginStatus.success ||
        loginResult.accessToken == null) {
      throw AuthException(loginResult.message ?? 'Facebook login failed.');
    }

    final Map<String, dynamic> userData = await FacebookAuth.instance
        .getUserData(fields: 'name,email,picture.width(200)');
    final String identity = (userData['name'] as String?) ??
        (userData['email'] as String?) ??
        'Facebook user';

    final SupabaseClient? client = _client;
    if (client == null) {
      await MockBackendStore.signIn(
        email: (userData['email'] as String?) ?? '$identity@facebook.local',
        displayName: identity,
      );
      return identity;
    }

    await MockBackendStore.signIn(
      email: (userData['email'] as String?) ?? '$identity@facebook.local',
      displayName: identity,
    );
    return identity;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}

    final SupabaseClient? client = _client;
    if (client == null) {
      await MockBackendStore.signOut();
      return;
    }

    await client.auth.signOut();
    await MockBackendStore.signOut();
  }

  Future<void> _syncLocalSession(User user) {
    final String identity = _storageKeyForUser(user);
    if (identity.isEmpty) {
      return Future<void>.value();
    }

    return MockBackendStore.signIn(
      email: identity,
      displayName: _displayNameForUser(user),
      phoneNumber: _phoneNumberForUser(user),
    );
  }

  String _storageKeyForUser(User user) {
    final String email = (user.email ?? '').trim();
    if (email.isNotEmpty) {
      return email;
    }

    final String id = user.id.trim();
    return id.isEmpty ? '' : '$id@users.supabase.local';
  }

  String? _displayNameForUser(User user) {
    final dynamic fullName = user.userMetadata?['full_name'];
    if (fullName is String && fullName.trim().isNotEmpty) {
      return fullName.trim();
    }

    final dynamic name = user.userMetadata?['name'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }

    return null;
  }

  String? _phoneNumberForUser(User user) {
    final dynamic phone = user.userMetadata?['phone'];
    if (phone is String && phone.trim().isNotEmpty) {
      return phone.trim();
    }

    return null;
  }
}
