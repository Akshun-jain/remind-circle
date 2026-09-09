import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountDeletionService {
  AccountDeletionService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> deleteAccount() async {
    // Delete the account and associated data on the server.
    await _deleteOnServerWithReauth();

    // The Admin SDK deletes the Firebase user on the server, but
    // Firebase Auth does not automatically clear this device's
    // locally cached session. Explicitly sign out here.
    await _auth.signOut();
  }

  static Future<void> _deleteOnServerWithReauth() async {
    try {
      await _callDeleteAccount();
    } on FirebaseFunctionsException catch (e) {
      if (e.code != 'failed-precondition') {
        throw Exception(e.message ?? 'Failed to delete account.');
      }

      // The server says the user's sign-in is too old.
      await _reauthenticateWithGoogle();
      await _callDeleteAccount();
    } catch (_) {
      throw Exception('Failed to delete account.');
    }
  }

  static Future<void> _callDeleteAccount() async {
    final callable = _functions.httpsCallable('deleteAccount');
    await callable.call();
  }

  static Future<void> _reauthenticateWithGoogle() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Google reauthentication failed.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await user.reauthenticateWithCredential(credential);
  }
}
