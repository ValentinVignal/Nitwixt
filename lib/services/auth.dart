import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitwixt/models/user_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user obj based on FirebaseUser
  UserAuth _userFromFirebaseUser(FirebaseUser user) {
    return user != null
      ? UserAuth(
          id: user.uid,
          email: user.email,
          isEmailVerified: user.isEmailVerified,
        ) : null;
  }

  // Auth change user stream
  Stream<UserAuth> get user {
    return _auth.onAuthStateChanged
        // .map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  // ? -------------------- Sign out --------------------

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

// * ------------------------------------------------------------
// * -------------------- Email and password --------------------
// * ------------------------------------------------------------
class AuthEmailPassword extends AuthService {
  // ? -------------------- Sign in --------------------
  Future signInEmailPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ? -------------------- Register --------------------
  Future registerEmailPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // create a new document for the with the uid
//      await DatabaseUser.createEmptyUser(id: user.uid);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future sendConfirmationEmail() async {
    return _auth.currentUser().then((FirebaseUser currentUser) {
      return currentUser.sendEmailVerification();
    }).catchError((error) {
      return error;
    });


  }
}
