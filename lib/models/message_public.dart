import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textwit/models/user_public.dart';

class MessagePublic {
  final String id;    // Id of the message
  final Timestamp date;   // When the message has been sent
  String text;      // The text of the message
  String userid;    // The id of the user who sent it

  MessagePublic({this.id, this.date, this.text, this.userid});

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['date'] = this.date;
    firebaseObject['text'] = this.text;
    firebaseObject['userid'] = this.userid;

    return firebaseObject;
  }

  MessagePublic.fromFirebaseObject(Map firebaseObject):
        id = firebaseObject['id'],
        date = firebaseObject['date'] {
    this.text = firebaseObject.containsKey('text') ? firebaseObject['text'] : '';
    this.userid = firebaseObject.containsKey('userid') ? firebaseObject['userid'] : '';
  }
}
