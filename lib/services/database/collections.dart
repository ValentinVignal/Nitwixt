import 'package:cloud_firestore/cloud_firestore.dart';

mixin CollectionNames {
  static const String users = 'users';
  static const String chats = 'chats';
  static const String messages = 'messages';

  // * ---------- Group collection ----------
  static const String userPrivate = 'user.private';
}

CollectionReference userCollection = FirebaseFirestore.instance.collection(CollectionNames.users);
CollectionReference chatCollection = FirebaseFirestore.instance.collection(CollectionNames.chats);
Query userPrivateCollection = FirebaseFirestore.instance.collectionGroup(CollectionNames.userPrivate);

