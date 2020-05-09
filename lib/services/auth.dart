import 'package:firebase_auth/firebase_auth.dart';
import 'package:textwit/models/user_auth.dart';
import 'package:textwit/services/database/database_old.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user obj based on FirebaseUser
  UserAuth _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? UserAuth(id: user.uid) : null;
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
      await DatabaseUserData(uid: user.uid).updateUserData('0', 'new crew member', 100);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}
