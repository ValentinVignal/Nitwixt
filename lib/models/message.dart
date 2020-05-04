import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textwit/models/user.dart';

class Message {
  final String id;
  final Timestamp date;
  String text;
  UserChat user;

  Message({this.id, this.date, this.text, this.user});
}