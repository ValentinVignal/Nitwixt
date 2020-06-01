import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitwixt/services/auth/auth_service.dart';

// * ------------------------------------------------------------
// * -------------------- Email and password --------------------
// * ------------------------------------------------------------
class AuthEmailPassword extends AuthService {

  // ? -------------------- Sign in --------------------
  Future signInEmailPassword(String email, String password) async {
    try {
      AuthResult result = await super.auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      return super.userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ? -------------------- Register --------------------
  Future registerEmailPassword(String email, String password) async {
    try {
      AuthResult result = await super.auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // create a new document for the with the uid
//      await DatabaseUser.createEmptyUser(id: user.uid);
      return super.userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future sendConfirmationEmail() async {
    return super.auth.currentUser().then((FirebaseUser currentUser) {
      return currentUser.sendEmailVerification();
    }).catchError((error) {
      return error;
    });
  }
}

