import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

String localizedFirebaseAuthError(
  FirebaseAuthException error,
  AppLocalizations localizations,
) {
  switch (error.code) {
    case 'invalid-email':
      return localizations.authFirebaseInvalidEmail;
    case 'email-already-in-use':
      return localizations.authFirebaseEmailAlreadyInUse;
    case 'weak-password':
      return localizations.authFirebaseWeakPassword;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return localizations.authFirebaseInvalidCredentials;
    case 'too-many-requests':
      return localizations.authFirebaseTooManyRequests;
    case 'network-request-failed':
      return localizations.authFirebaseNetworkError;
    case 'requires-recent-login':
      return localizations.authFirebaseRequiresRecentLogin;
    case 'user-disabled':
      return localizations.authFirebaseUserDisabled;
    case 'operation-not-allowed':
      return localizations.authFirebaseOperationNotAllowed;
    default:
      return localizations.authFirebaseGenericError;
  }
}
