import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  static Future<String> getImageLink(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }
  static Future<void> delete(String path) async{
    await _storage.ref(path).delete();
  }

  static Future<String> uploadFile(File file, String destination) async {
    final fileName = basename(file.path);

    try{
      final ref = _storage.ref().child(destination+fileName);
      await ref.putFile(file);
      return ref.fullPath;
    }catch(e){
      throw Exception("Upload error");
    }
  }
}