import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseFile {
  String path;

  DatabaseFile({
    this.path,
  });

  static Future<String> urlFromPath (String path) async {
      String downloadURL;
      try {
        StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
        downloadURL = await storageReference.getDownloadURL();
      } on Exception catch (exc) {
        downloadURL = '';
      }
      return downloadURL;
  }

  Future<String> get url async {
    return await urlFromPath(this.path);
  }

  static Image imageFromUrl (String url, {Image defaultImage}) {
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

  static Future<Image> imageFromPath(String path, {Image defaultImage}) async {
    String url = await urlFromPath(path);
    return imageFromUrl(url, defaultImage: defaultImage);
  }

  Future<Image> get image async {
    return await imageFromPath(this.path);

  }
}