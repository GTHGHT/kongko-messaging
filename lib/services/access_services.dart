import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:messaging_app_update/services/storage_services.dart';
import 'package:messaging_app_update/model/user_model.dart';

import 'api.dart';

class AccessServices extends ChangeNotifier {
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();
  UserModel _userModel = UserModel.initial();

  UserModel get userModel => _userModel;

  void showLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  Future<void> changeImage(File? newImage) async {
    if (newImage == null) return;

    try {
      showLoading(true);
      final firestore = FirebaseFirestore.instance;
      int counter = 0;
      final location =
          await StorageService.uploadFile(newImage, "profile_picture/");
      if (_userModel.image != "default_profile.png") {
        await StorageService.delete(_userModel.image);
      }
      final groups = await firestore
          .collection('users/${_userModel.uid}/groups')
          .get()
          .then((QuerySnapshot snapshot) {
        return snapshot.docs;
      });

      final personalChats = await firestore
          .collection('users/${_userModel.uid}/personalChats')
          .get()
          .then((QuerySnapshot snapshot) {
        return snapshot.docs;
      });

      var batch = firestore.batch();
      for (DocumentSnapshot i in groups) {
        final groupMember = firestore
            .collection("groups/${i["id"]}/members")
            .doc(_userModel.uid);
        batch.update(groupMember, {'image': location});
        if (++counter >= 500) await batch.commit();
      }

      for (DocumentSnapshot i in personalChats) {
        final personatChatGroup = firestore
            .collection("groups/${i["id"]}/members")
            .doc(_userModel.uid);
        batch.update(personatChatGroup, {'image': location});
        if (++counter >= 500) await batch.commit();
        final friend = firestore
            .collection("users/${i["uid"]}/personalChats")
            .doc(_userModel.uid);
        batch.update(friend, {'image': location});
        if (++counter >= 500) await batch.commit();
      }
      final currentUsers = firestore.collection("users").doc(_userModel.uid);
      batch.update(currentUsers, {'image': location});
      await batch.commit();
      _userModel.image = location;
      showLoading(false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeUsername(String newUsername) async {
    if (newUsername == userModel.username) return;

    showLoading(true);
    try {
      final firestore = FirebaseFirestore.instance;
      int counter = 0;
      final groups = await firestore
          .collection('users/${_userModel.uid}/groups')
          .get()
          .then((QuerySnapshot snapshot) {
        return snapshot.docs;
      });

      final personalChats = await firestore
          .collection('users/${_userModel.uid}/personalChats')
          .get()
          .then((QuerySnapshot snapshot) {
        return snapshot.docs;
      });

      var batch = firestore.batch();
      for (DocumentSnapshot i in groups) {
        final groupMember = firestore
            .collection("groups/${i["id"]}/members")
            .doc(_userModel.uid);
        final groupMessages = await firestore
            .collection("groups/${i["id"]}/messages")
            .where('sender_uid', isEqualTo: _userModel.uid)
            .get()
            .then((QuerySnapshot snapshot) => snapshot.docs);
        for (DocumentSnapshot j in groupMessages) {
          final groupMessages =
              firestore.collection("groups/${i["id"]}/messages").doc(j.id);
          batch.update(groupMessages, {'sender': newUsername});
          if (++counter >= 500) await batch.commit();
        }
        batch.update(groupMember, {'username': newUsername});
        if (++counter >= 500) await batch.commit();
      }

      for (DocumentSnapshot i in personalChats) {
        final groupMember = firestore
            .collection("groups/${i["id"]}/members")
            .doc(_userModel.uid);
        final groupMessages = await firestore
            .collection("groups/${i["id"]}/messages")
            .where('sender_uid', isEqualTo: _userModel.uid)
            .get()
            .then((QuerySnapshot snapshot) => snapshot.docs);
        for (DocumentSnapshot j in groupMessages) {
          final groupMessages =
              firestore.collection("groups/${i["id"]}/messages").doc(j.id);
          batch.update(groupMessages, {'sender': newUsername});
          if (++counter >= 500) await batch.commit();
        }
        batch.update(groupMember, {'username': newUsername});
        if (++counter >= 500) await batch.commit();
      }

      final currentUsers = firestore.collection("users").doc(_userModel.uid);
      batch.update(currentUsers, {'username': newUsername});
      await batch.commit();
      _userModel.username = newUsername;

      showLoading(false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeEmail(String newEmail) async {
    if (newEmail == userModel.email) return;

    showLoading(true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateEmail(newEmail);
        await Api(collection: "users", doc: _userModel.uid)
            .updateDocument({'email': newEmail});
        logout();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    showLoading(false);
  }

  Future<bool> register({
    required TextEditingController username,
    required TextEditingController email,
    required TextEditingController password,
    required TextEditingController confirmPassword,
    required void Function(String message) showSnackBar,
  }) async {
    try {
      if (username.text.isEmpty ||
          email.text.isEmpty ||
          password.text.isEmpty ||
          confirmPassword.text.isEmpty) {
        showSnackBar("Isi Semua Form");
        return false;
      }
      if (password.text.length < 8) {
        showSnackBar("Password Minimal 8 Karakter");
        return false;
      } else if (password.text != confirmPassword.text) {
        showSnackBar("Password tidak sama");
        return false;
      }
      showLoading(true);
      email.text = email.text.toLowerCase();
      await _auth.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      await addUserDoc(
        username: username.text,
        email: email.text,
      );
      _userModel = UserModel(
        uid: _auth.currentUser!.uid,
        username: username.text,
        image: "default_profile.png",
        email: email.text,
      );
      await _storage.write(key: "KEY_USERNAME", value: email.text);
      await _storage.write(key: "KEY_PASSWORD", value: password.text);
      showSnackBar("Berhasil Registrasi");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        showSnackBar("Email Sudah Terdaftar, Silahkan Login");
      } else if (e.code == "invalid-email") {
        showSnackBar("Email Anda Tidak Sah");
      } else if (e.code == "weak-password") {
        showSnackBar("Password Anda Terlalu Lemah");
      } else {
        showSnackBar(e.message ?? "Terjadi Kesalahan");
      }
      return false;
    } finally {
      showLoading(false);
    }
  }

  Future<void> addUserDoc(
      {required String email, required String username}) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = Api(collection: 'users', doc: user.uid);
      await userRef.setDocument({
        'uid': user.uid,
        'username': username,
        'image': "default_profile.png",
        'email': email,
      });
    }
  }

  Future<void> loadUserDoc() async {
    final userRef = await Api(
      collection: 'users',
      doc: _auth.currentUser!.uid,
    ).getDocument();
    _userModel = UserModel(
      uid: _auth.currentUser!.uid,
      username: userRef["username"],
      image: userRef["image"],
      email: userRef["email"],
    );
  }

  Future<bool> loginUserFromStorage() async {
    if (await _storage.read(key: 'KEY_USERNAME') != null) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: await _storage.read(key: 'KEY_USERNAME') ?? '',
          password: await _storage.read(key: 'KEY_PASSWORD') ?? '',
        );
        await loadUserDoc();
        return true;
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> login({
    required TextEditingController email,
    required TextEditingController password,
    required void Function(String message) showSnackBar,
  }) async {
    try {
      if (email.text.isEmpty || password.text.length < 5) {
        showSnackBar("Isi Email dan Password Anda");
        return false;
      }
      showLoading(true);
      email.text = email.text.toLowerCase();
      await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      await loadUserDoc();
      await _storage.write(key: "KEY_USERNAME", value: email.text);
      await _storage.write(key: "KEY_PASSWORD", value: password.text);
      showSnackBar("Berhasil Login");
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        showSnackBar("Email Tidak Ditemukan, Silahkan Register");
      } else if (e.code == "invalid-email") {
        showSnackBar("Email Anda Tidak Sah");
      } else if (e.code == "wrong-password") {
        showSnackBar("Password Anda Salah");
      } else {
        showSnackBar(e.message ?? "Terjadi Kesalahan");
      }
      return false;
    } finally {
      showLoading(false);
    }
  }

  void logout() {
    _auth.signOut();
    _userModel = UserModel.initial();
    _storage.deleteAll().ignore();
    notifyListeners();
  }
}