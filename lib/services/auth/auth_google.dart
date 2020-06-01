import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitwixt/services/auth/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

// * ------------------------------------------------------------
// * -------------------- Google --------------------
// * ------------------------------------------------------------

class AuthGoogle extends AuthService {

  // ? -------------------- Sign in --------------------
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await super.auth.signInWithCredential(credential);
      final FirebaseUser firebaseUser = authResult.user;

      assert(!firebaseUser.isAnonymous);
      assert(await firebaseUser.getIdToken() != null);

      final FirebaseUser currentUser = await super.auth.currentUser();
      assert(firebaseUser.uid == currentUser.uid);
      print('firebase user');
      print(firebaseUser);
      final user = userFromFirebaseUser(firebaseUser);
      return user;
    } catch (e) {
      print('GoogleSignIn error ${e.toString()}');
    }
    print('end');
  }

//  // ? -------------------- Sign in --------------------
//  @override
//  Future signOut() async {
//    try {
//      print('in signout google');
//      await googleSignIn.signOut();
//      googleSignIn.
//      return await super.signOut();
//    } catch (e) {
//      print(e.toString());
//    }
//  }
}
