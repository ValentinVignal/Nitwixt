import 'package:firebase_auth/firebase_auth.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/auth/auth_service.dart';

// * ------------------------------------------------------------
// * -------------------- Email and password --------------------
// * ------------------------------------------------------------
class AuthEmailPassword extends AuthService {
  // ? -------------------- Sign in --------------------
  Future<models.UserAuth> signInEmailPassword(String email, String password) async {
    try {
      final UserCredential result = await super.auth.signInWithEmailAndPassword(email: email, password: password);
      final User user = result.user;
      return super.userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ? -------------------- Register --------------------
  Future<models.UserAuth> registerEmailPassword(String email, String password) async {
    try {
      final UserCredential result = await super.auth.createUserWithEmailAndPassword(email: email, password: password);
      final User user = result.user;

      // create a new document for the with the uid
//      await DatabaseUser.createEmptyUser(id: user.uid);
      return super.userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> sendConfirmationEmail() async {
    final User currentUser = auth.currentUser;
    try {
      await currentUser.sendEmailVerification();
      return true;
    } catch (error) {
      return false;
    }
  }
}
