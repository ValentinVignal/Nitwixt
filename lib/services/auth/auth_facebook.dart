import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:nitwixt/services/auth/auth.dart';

class AuthFacebook extends AuthService {
  // ? -------------------- Sign in --------------------
  Future signInWithFacebook() async {
    try {
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      final FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile', 'user_friends']);
      if (facebookLoginResult.status != FacebookLoginStatus.loggedIn) {
        // Error or cancelled
        print(facebookLoginResult.errorMessage);
        return ;
      }
      AuthCredential authCredential = FacebookAuthProvider.getCredential(accessToken: facebookLoginResult.accessToken.token);
      final AuthResult authResult = await super.auth.signInWithCredential(authCredential);
      final FirebaseUser firebaseUser = authResult.user;

//      AuthResult authResult = await auth.signInWithCustomToken(token: facebookLoginResult.accessToken.token);
//      FirebaseUser firebaseUser = authResult.user;

      assert(!firebaseUser.isAnonymous);
      assert(await firebaseUser.getIdToken() != null);
      final FirebaseUser currentUser = await super.auth.currentUser();
      assert(firebaseUser.uid == currentUser.uid);
      final user = userFromFirebaseUser(firebaseUser);
      return user;
    } catch (e) {
      print(e.toString());
    }
  }
}
