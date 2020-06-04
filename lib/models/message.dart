import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/message_public.dart';

class Message {
  final String id;    // Id of the message
  final Timestamp date;   // When the message has been sent
  String text;      // The text of the message
  String userid;    // The user who sent the message

  Message({this.id, this.date, this.text, this.userid});

  MessagePublic toMessagePublic() {
    return MessagePublic(id: this.id, date: this.date, text: this.text, userid: this.userid);
  }

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['date'] = this.date;
    firebaseObject['text'] = this.text;
    firebaseObject['userid'] = this.userid;

    return firebaseObject;
  }

  Message.fromFirebaseObject(String id, Map firebaseObject):
        id = id,
        date = firebaseObject['date'] {
    this.text = firebaseObject.containsKey('text') ? firebaseObject['text'] : '';
    this.userid = firebaseObject.containsKey('userid') ? firebaseObject['userid'] : '';
  }


}