import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseFile {
  String path;

  DatabaseFile({
    this.path,
  });

  Future<bool> get exists async {
    bool _exists = true;
    try {
      StorageReference storageReference = FirebaseStorage.instance.ref().child(this.path);
      await storageReference.getDownloadURL();
    } on Exception catch (exc) {
      _exists = false;
    }
    return _exists;
  }

  Future<String> get url async {
    String downloadURL;
    try {
      StorageReference storageReference = FirebaseStorage.instance.ref().child(this.path);
      downloadURL = await storageReference.getDownloadURL();
    } on Exception catch (exc) {
      downloadURL = '';
    }
    return downloadURL;
  }

  static Image imageFromUrl(String url, {Image defaultImage}) {
    if (url.isEmpty) {
      if (defaultImage != null) {
        return defaultImage;
      } else {
        return Image.asset('assets/images/defaultProfilePicture.png');
      }
    } else {
      return Image.network(url);
    }
  }

  Future<Image> get image async {
    return imageFromUrl(await this.url);
  }

  ///
  Future uploadImage({Image image, String url, bool replace = true}) async {
    assert((image == null) != (url == null));
    if (replace || !(await this.exists)) {
      if (url != null) {
        image = imageFromUrl(url);
      }
    }
  }

  /// replace: if false : won't upload the file if it already exists
  void uploadFile(File file, {bool replace = true}) async {
    if (replace || !(await this.exists)) {
      final StorageReference storageReference = FirebaseStorage.instance.ref().child(this.path);
      final StorageUploadTask storageUploadTask = storageReference.putFile(file);
    }
  }
}
