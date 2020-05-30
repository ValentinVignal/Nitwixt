// Information of a chat in a user profile
class UserPublic {
  final String id;
  String name;
  final String username;

  UserPublic({ this.id, this.name, this.username });

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['name'] = this.name;
    firebaseObject['username'] = this.username;

    return firebaseObject;
  }

  UserPublic.fromFirebaseObject(String id, Map firebaseObject):
      id = id,
      username = firebaseObject['username'] {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : 'Unkown Name';
  }
}