import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:nitwixt/services/auth/auth.dart';
import 'package:nitwixt/models/models.dart' as models;

class AuthFacebook extends AuthService {
  // ? -------------------- Sign in --------------------
  Future<models.UserAuth> signInWithFacebook() async {
    try {
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      final FacebookLoginResult facebookLoginResult = await facebookLogin.logIn(<String>[
        'email',
        'public_profile',
        'user_friends',
      ]);
      if (facebookLoginResult.status != FacebookLoginStatus.loggedIn) {
        // Error or cancelled
        print(facebookLoginResult.errorMessage);
        return null;
      }
      final AuthCredential authCredential = FacebookAuthProvider.credential(facebookLoginResult.accessToken.token);
      final UserCredential authResult = await super.auth.signInWithCredential(authCredential);
      final User firebaseUser = authResult.user;

//      AuthResult authResult = await auth.signInWithCustomToken(token: facebookLoginResult.accessToken.token);
//      FirebaseUser firebaseUser = authResult.user;

      assert(!firebaseUser.isAnonymous);
      assert(await firebaseUser.getIdToken() != null);
      final User currentUser = super.auth.currentUser;
      assert(firebaseUser.uid == currentUser.uid);
      final models.UserAuth user = userFromFirebaseUser(firebaseUser);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
