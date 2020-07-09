import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';

// Public user
class User {
  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  List<String> chats = [];
  List<String> pushToken = [];
  String defaultPhotoUrl;

  // * -------------------- Constructor --------------------

  User({
    this.id,
    this.username,
    this.name,
    this.chats,
    this.pushToken,
    this.defaultPhotoUrl='',
  });

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
      'defaultPhotoUrl': this.defaultPhotoUrl,
    };
  }

  User.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.username = firebaseObject.containsKey('username') ? firebaseObject['username'] : '';
      this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
      this.chats = firebaseObject.containsKey('chats') ? List.from(firebaseObject['chats']) : [];
      this.pushToken = firebaseObject.containsKey('pushToken') ? List.from(firebaseObject['pushToken']) : [];
      this.defaultPhotoUrl = firebaseObject.containsKey('defaultPhotoUrl') ? firebaseObject['defaultPhotoUrl'] : '';
    }
  }

  bool get hasUsername {
    return this.username != null && this.username.isNotEmpty;
  }

  bool get hasNoUsername {
    return !this.hasUsername;
  }

  // * -------------------- Profile Picture --------------------

  String get profilePicturePath {
    return 'users/${this.id}/profilePicture.jpg';
  }

  Future<String> get profilePictureUrl async {
    String url = await DatabaseFile(path: this.profilePicturePath).url;
    return url.isNotEmpty ? url:  this.defaultPhotoUrl;
  }
}
