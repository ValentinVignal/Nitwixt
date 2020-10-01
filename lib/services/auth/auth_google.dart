import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:nitwixt/services/auth/auth_service.dart';
import 'package:nitwixt/models/models.dart' as models;

// * ------------------------------------------------------------
// * -------------------- Google --------------------
// * ------------------------------------------------------------

class AuthGoogle extends AuthService {
  // ? -------------------- Sign in --------------------
  Future<models.UserAuth> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await super.auth.signInWithCredential(credential);
      final User firebaseUser = authResult.user;

      assert(!firebaseUser.isAnonymous);
      assert(await firebaseUser.getIdToken() != null);

      final User currentUser = super.auth.currentUser;
      assert(firebaseUser.uid == currentUser.uid);
      final models.UserAuth user = userFromFirebaseUser(firebaseUser);
      return user;
    } catch (e) {
      print('GoogleSignIn error ${e.toString()}');
      return null;
    }
  }
}
