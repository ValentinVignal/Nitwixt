import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Id of the message
  final Timestamp date; // When the message has been sent
  String text; // The text of the message
  String userid; // The user who sent the message
  Map<String, String> reacts;

  Message({
    this.id,
    this.date,
    this.text,
    this.userid,
    this.reacts,
  }) {
    if(this.reacts == null) {
      this.reacts = Map<String, String>();
    }
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['date'] = this.date;
    firebaseObject['text'] = this.text;
    firebaseObject['userid'] = this.userid;
    firebaseObject['reacts'] = this.reacts;

    return firebaseObject;
  }

  Message.fromFirebaseObject(String id, Map firebaseObject)
      : id = id,
        date = firebaseObject['date'] {
    this.text = firebaseObject.containsKey('text') ? firebaseObject['text'] : '';
    this.userid = firebaseObject.containsKey('userid') ? firebaseObject['userid'] : '';
    this.reacts = firebaseObject.containsKey('reacts') ? Map.from(firebaseObject['reacts']) : Map<String, String>();
  }

}
