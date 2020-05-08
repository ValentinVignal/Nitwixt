class ChatPublic {
  final String id;
  String name;

  ChatPublic({ this.id, this.name });

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['name'] = this.name;

    return firebaseObject;
  }

  ChatPublic.fromFirebaseObject(Map firebaseObject):
      id = firebaseObject['id'] {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
  }
}
