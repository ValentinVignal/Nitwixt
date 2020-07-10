import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionNames {
  static final String users = 'users';
  static final String chats = 'chats';
  static final String messages = 'messages';
}

CollectionReference userCollection = Firestore.instance.collection(CollectionNames.users);
CollectionReference chatCollection = Firestore.instance.collection(CollectionNames.chats);

