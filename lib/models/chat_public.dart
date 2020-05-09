class ChatPublic {
  final String id;
  String name;

  ChatPublic({ this.id, this.name });

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['name'] = this.name;

    return firebaseObject;
  }

  ChatPublic.fromFirebaseObject(String id, Map firebaseObject):
      id = id {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
  }
}
