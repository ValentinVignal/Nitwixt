import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';



// Public user
class User {
  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  List<String> chats = [];
  List<String> pushToken = [];
  String _profilePictureUrl;

  // * -------------------- Constructor --------------------

  User({this.id, this.username, this.name, this.chats, this.pushToken});

  // * -------------------- To Public --------------------

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
    this.chats.sort();
    return {
      'id': this.id,
      'username': this.username,
      'name': this.name,
      'chats': this.chats,
      'pushToken': this.pushToken,
    };

  }

  User.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.username = firebaseObject.containsKey('username') ? firebaseObject['username'] : '';
      this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
      this.chats = firebaseObject.containsKey('chats') ? List.from(firebaseObject['chats']) : [];
      this.pushToken = firebaseObject.containsKey('pushToken') ? List.from(firebaseObject['pushToken']) : [];
    }
  }

  bool get hasUsername {
    return this.username == null || this.username.isEmpty;
  }

  // * -------------------- Profile Picture --------------------

  String get profilePicturePath {
    return 'users/${this.id}/profilePicture.jpg';
  }

  Future<String> get profilePictureUrl async {
    if (_profilePictureUrl != null && _profilePictureUrl.isNotEmpty) {
      return _profilePictureUrl;
    } else {
      StorageReference storageReference = FirebaseStorage.instance.ref().child(this.profilePicturePath);
      String downloadURL;
      try {
        downloadURL = await storageReference.getDownloadURL();
      } catch (err) {
        downloadURL = '';
      }
      _profilePictureUrl = downloadURL;
      return downloadURL;
    }
  }

  Future<Image> get profilePicture async {
    String url = await this.profilePictureUrl;
    if (url.isEmpty) {
      return Image.asset('assets/images/defaultProfilePicture.png');
    } else {
      return Image.network(url);
    }

  }
}
