import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseFiles {
  String path;

  DatabaseFiles({
    this.path,
  });

  Future<bool> get exists async {
    bool _exists = true;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(this.path);
    try {
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
    if (url == null || url.isEmpty) {
      if (defaultImage != null) {
        return defaultImage;
      } else {
//        return Image.asset('assets/images/defaultProfilePicture.png');
      return null;
      }
    } else {
      return Image.network(url, errorBuilder: (BuildContext context, Object object, StackTrace stackTrace) {
        return SizedBox.shrink();
      },);
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
  Future uploadFile(File file, {bool replace = true}) async {
    if (replace || !(await this.exists)) {
      final StorageReference storageReference = FirebaseStorage.instance.ref().child(this.path);
      final StorageUploadTask storageUploadTask = storageReference.putFile(file);
      return new Future.value('Uploaded');
    } else {
      return new Future.value('No upload');
    }
  }
}
