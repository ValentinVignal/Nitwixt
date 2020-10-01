// Nitwixt user
class UserAuth {

  UserAuth({
    this.id,
    this.email,
    this.isEmailVerified,
    this.photoUrl,
  });

  final String id;
  String email;
  bool isEmailVerified;
  String photoUrl;

  bool get hasPhoto {
    return photoUrl != null && photoUrl.isNotEmpty;
  }
}
