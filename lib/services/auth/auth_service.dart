import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:nitwixt/models/user_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nitwixt/services/database/database.dart' as database;

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin facebookLogin = FacebookLogin();

  // Create user obj based on FirebaseUser
  UserAuth userFromFirebaseUser(FirebaseUser firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    UserAuth userAuth = UserAuth(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      isEmailVerified: firebaseUser.isEmailVerified,
      photoUrl: firebaseUser.photoUrl,
    );
    return userAuth;
  }

  // Auth change user stream
  Stream<UserAuth> get user {
    return auth.onAuthStateChanged
        .map(userFromFirebaseUser);
  }

  // Sign out
  Future signOut({String pushToken}) async {
    try {
      FirebaseUser firebaseUser;
      if (pushToken != null) {
        // We have to delete it
        firebaseUser = await auth.currentUser();
//        await database.DatabasePushToken(id: firebaseUser.uid).removeToken(pushToken);
      }
      var res = await auth.signOut().then((res) async {
        if (await googleSignIn.isSignedIn()) {
          return googleSignIn.signOut();
        } else if (await facebookLogin.isLoggedIn) {
          return facebookLogin.logOut();
        } else {
          return res;
        }
      });
      if (pushToken != null) {
        return await database.DatabasePushToken(id: firebaseUser.uid).removeToken(pushToken);
      } else {
        return res;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
