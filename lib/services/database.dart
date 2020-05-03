import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textwit/models/brew.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/models/chat.dart';

class DatabaseUserData {
  final String uid;

  DatabaseUserData({this.uid});

  // collection reference
  final CollectionReference brewCollection = Firestore.instance.collection('brews');

  Future updateUserData(String sugars, String name, int strength) async {
    return await brewCollection.document(uid).setData({'sugars': sugars, 'name': name, 'strength': strength});
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data['name'],
      sugars: snapshot.data['sugars'],
      strength: snapshot.data['strength'],
    );
  }

  // get user doc stream
  Stream<UserData> get userData {
    return brewCollection.document(uid).snapshots().map(_userDataFromSnapshot);
  }

  //Brew lit from Snapshot
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Brew(
        name: doc.data['name'] ?? '',
        sugars: doc.data['sugars'] ?? '0',
        strength: doc.data['strength'] ?? 0,
      );
    }).toList();
  }

  // Get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots().map(_brewListFromSnapshot);
  }
}

class DatabaseUser {
  final String uid;

  DatabaseUser({this.uid});

  final CollectionReference userCollection = Firestore.instance.collection('users');

  User _userFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, UserChat> chatsMap = new Map();
    //    final AuthService _auth = AuthService();
    snapshot.data['chats'].forEach((key, value) {
      chatsMap[key] = UserChat(
        id: key,
        name: value['name'],
      );
    });

    return User(id: uid, username: snapshot.data['username'], name: snapshot.data['name'], chats: chatsMap);
  }

  Stream<User> get user {
    return userCollection.document(uid).snapshots().map(_userFromSnapshot);
  }

  List<UserChat> _userChatListFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.data['chats'].map<String, UserChat>((key, value) {
      String key;
      return MapEntry(
        key,
        UserChat(
          id: key,
          name: value['name'],
        ),
      );
    }).values.toList();
  }

  Stream<List<UserChat>> get userChatList {
    return userCollection.document(uid).snapshots().map(_userChatListFromSnapshot);
  }
}

class DatabaseChat {
  final String id;

  DatabaseChat({this.id});

  final CollectionReference chatCollection = Firestore.instance.collection('chats');

  Chat _chatFromSnapshot(DocumentSnapshot snapshot) {
    return Chat(
      id: id,
      name: snapshot.data['name'],
    );
  }
}
