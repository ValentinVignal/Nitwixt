import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textwit/models/brew.dart';
import 'package:textwit/models/user.dart';


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

  User _userFromSnapShot(DocumentSnapshot snapshot) {
    return User(
      id: uid,
      username: snapshot.data['username'],
      name: snapshot.data['name']
    );
  }

  Stream<User> get user {
    return userCollection.document(uid).snapshots().map(_userFromSnapShot);
  }
}
