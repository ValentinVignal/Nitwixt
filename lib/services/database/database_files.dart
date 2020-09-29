import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseFiles {
  DatabaseFiles({
    this.path,
  });

  String path;

  Future<bool> get exists async {
    bool _exists = true;
    final StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
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
      final StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
      downloadURL = await storageReference.getDownloadURL() as String;
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
      return Image.network(
        url,
        errorBuilder: (BuildContext context, Object object, StackTrace stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }
  }

  Future<Image> get image async {
    return imageFromUrl(await url);
  }

  ///
  Future uploadImage({Image image, String url, bool replace = true}) async {
    assert((image == null) != (url == null));
    if (replace || !(await exists)) {
      if (url != null) {
        image = imageFromUrl(url);
      }
    }
  }

  /// replace: if false : won't upload the file if it already exists
  Future<String> uploadFile(File file, {bool replace = true}) async {
    if (replace || !(await exists)) {
      final StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
      final StorageUploadTask storageUploadTask = storageReference.putFile(file);
      return Future<String>.value('Uploaded');
    } else {
      return Future<String>.value('No upload');
    }
  }
}
