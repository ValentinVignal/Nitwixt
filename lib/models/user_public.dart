// Information of a chat in a user profile
class UserPublic {
  final String id;
  String name;
  final String username;

  UserPublic({ this.id, this.name, this.username });

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['name'] = this.name;
    firebaseObject['username'] = this.username;

    return firebaseObject;
  }

  UserPublic.fromFirebaseObject(Map firebaseObject):
      id = firebaseObject['id'],
      username = firebaseObject['username'] {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : 'Unkown Name';
  }
}
