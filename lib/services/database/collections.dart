import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference userCollection = Firestore.instance.collection('users');
CollectionReference chatCollection = Firestore.instance.collection('chats');