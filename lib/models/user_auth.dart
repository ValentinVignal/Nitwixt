import 'package:nitwixt/services/database/database.dart';
import 'package:firebase_storage/firebase_storage.dart';


// Textwit user
class UserAuth {
  final String id;
  String email;
  bool isEmailVerified;
  String photoUrl;

  UserAuth({
    this.id,
    this.email,
    this.isEmailVerified,
    this.photoUrl,
  });

  bool get hasPhoto {
    return this.photoUrl != null && this.photoUrl.isNotEmpty;
  }
}
