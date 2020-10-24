import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:nitwixt/models/user_auth.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/models/models.dart' as models;

class AuthService {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();

  static Future<void> initialize() async {
    return Firebase.initializeApp();
  }

  // Create user obj based on FirebaseUser
  UserAuth userFromFirebaseUser(User firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    final UserAuth userAuth = UserAuth(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      isEmailVerified: firebaseUser.emailVerified,
      photoUrl: firebaseUser.photoURL,
    );
    return userAuth;
  }

  // Auth change user stream
  Stream<UserAuth> get user {
    return auth.authStateChanges().map(userFromFirebaseUser);
  }

  // Sign out
  Future<void> signOut({models.UserPushTokens userPushTokens}) async {
    try {
      User firebaseUser;
      if (userPushTokens != null && userPushTokens.current != null) {
        // We have to delete it
        firebaseUser = auth.currentUser;
//        await database.DatabasePushToken(id: firebaseUser.uid).removeToken(pushToken);
      }
      final void res = await auth.signOut().then((void res) async {
        if (await googleSignIn.isSignedIn()) {
          return googleSignIn.signOut();
        } else if (await facebookLogin.isLoggedIn) {
          return facebookLogin.logOut();
        } else {
          return res;
        }
      });
      if (userPushTokens != null && userPushTokens.current != null) {
        final String currentPushToken = userPushTokens.removeCurrent();
        print('current Push Token $currentPushToken');
        print('firebase user $firebaseUser');
        if (currentPushToken != null) {
          // Something has been popped
          return await database.DatabaseUserPushTokens(userId: firebaseUser.uid).update(<String, dynamic>{
            models.UserPushTokensKeys.tokens: userPushTokens.toFirebaseObject()[models.UserPushTokensKeys.tokens]
          });
        }
      } else {
        return res;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
