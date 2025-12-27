import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:martfury/core/app_config.dart';

class GoogleSignInException implements Exception {
  GoogleSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleSignInNotConfiguredException extends GoogleSignInException {
  GoogleSignInNotConfiguredException()
      : super(
          'Google Sign-In is not configured. '
          'Follow the steps in docs/12_social_login_setup.md.',
        );
}

class GoogleSignInCancelledException extends GoogleSignInException {
  GoogleSignInCancelledException()
      : super('Google Sign-In was cancelled by the user.');
}

class GoogleSignInTokenException extends GoogleSignInException {
  GoogleSignInTokenException()
      : super('Google Sign-In failed to return a valid ID token.');
}

class GoogleAuthFacade {
  GoogleAuthFacade({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? _buildGoogleSignIn();

  final GoogleSignIn _googleSignIn;

  static bool get isConfigured => AppConfig.enableGoogleSignIn;

  Future<String> signInAndGetIdToken() async {
    if (!isConfigured) {
      throw GoogleSignInNotConfiguredException();
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw GoogleSignInCancelledException();
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw GoogleSignInTokenException();
    }

    return idToken;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, stack) {
      debugPrint('GoogleSignIn signOut failed: $e');
      debugPrint('$stack');
    }
  }

  static GoogleSignIn _buildGoogleSignIn() {
    if (AppConfig.googleClientId == null ||
        AppConfig.googleServerClientId == null) {
      throw GoogleSignInNotConfiguredException();
    }

    return GoogleSignIn(
      clientId: AppConfig.googleClientId,
      serverClientId: AppConfig.googleServerClientId,
      scopes: const ['email'],
    );
  }
}
