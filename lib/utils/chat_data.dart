import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:messaging_app_update/services/api.dart';
import 'package:messaging_app_update/model/user_model.dart';

import '../services/storage_services.dart';
import '../model/group_model.dart';

class ChatData extends ChangeNotifier {
  GroupModel _groupModel = GroupModel.initial();
  UserModel _currentUserModel = UserModel.initial();
  bool _isAdmin = false;
  String pcUid = "";

  String _messageText = "";
  bool loading = false;

  Api api = Api(collection: "");
  final _auth = FirebaseAuth.instance;

  showLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void send() async {
    loading = true;
    notifyListeners();
    await api.addDocument({
      'text': _messageText,
      'sender': _currentUserModel.username,
      'sender_uid': _auth.currentUser!.uid,
      'sent_time': FieldValue.serverTimestamp(),
    });
    _messageText = "";
    loading = false;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages() {
    return api.streamCollection(sortBy: 'sent_time');
  }

  Future<void> loadDesc() async {
    _groupModel.desc ??= await Api(collection: "groups", doc: _groupModel.id)
          .getDocument()
          .then((value) => value.data()!["desc"]);
    isAdmin = await Api(
      collection: "groups/${_groupModel.id}/members",
      doc: _auth.currentUser!.uid,
    ).getDocument().then((value) =>
        value.data()!.containsKey("isAdmin") ? value["isAdmin"] : false);
    notifyListeners();
  }

  loadUser() async {
    final _currentUserDoc =
        await Api(collection: "users", doc: _auth.currentUser!.uid)
            .getDocument();
    _currentUserModel =
        UserModel.fromMap(_currentUserDoc.data() as Map<String, dynamic>);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMembers() {
    return Api(collection: "groups/${_groupModel.id}/members")
        .streamCollection();
  }

  Future<void> changeGroupImage(File? newImage) async {
    if (newImage == null) return;

    try {
      showLoading(true);
      final firestore = FirebaseFirestore.instance;
      final groupMembers =
          await firestore.collection("groups/${_groupModel.id}/members").get();
      final location =
          await StorageService.uploadFile(newImage, "group_picture/");
      if (_groupModel.image != "default_group.png") {
        await StorageService.delete(_groupModel.image);
      }
      int counter = 0;
      final batch = firestore.batch();
      for (DocumentSnapshot<Map<String, dynamic>> i in groupMembers.docs) {
        final groupMember = firestore
            .collection("users/${i['uid']}/groups")
            .doc(_groupModel.id);
        batch.update(groupMember, {'image': location});
        if (++counter >= 500) await batch.commit();
      }
      await Api(collection: "groups", doc: _groupModel.id)
          .updateDocument({'image': location});
      await batch.commit();
      _groupModel.image = location;
      showLoading(false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> changeGroupTitle(String newTitle) async {
    final firestore = FirebaseFirestore.instance;
    final groupMembers =
        await firestore.collection("groups/${_groupModel.id}/members").get();
    if (groupMembers.size > 0 && newTitle != _groupModel.title) {
      showLoading(true);
      int counter = 0;
      final batch = firestore.batch();
      for (DocumentSnapshot<Map<String, dynamic>> i in groupMembers.docs) {
        final groupMember = firestore
            .collection("users/${i['uid']}/groups")
            .doc(_groupModel.id);
        batch.update(groupMember, {'title': newTitle});
        if (++counter >= 500) await batch.commit();
      }
      await firestore.collection("groups").doc(_groupModel.id).update({
        'title': newTitle,
      });
      await batch.commit();
      _groupModel.title = newTitle;
      showLoading(false);
    }
  }

  Future<void> changeGroupDesc(String newDesc) async {
    if (_groupModel.desc != newDesc) {
      await Api(collection: "groups", doc: _groupModel.id)
          .updateDocument({'desc': newDesc});
      _groupModel.desc = newDesc;
      notifyListeners();
    }
  }

  Future<void> addMember(String uid) async {
    if (isAdmin) {
      final memberDoc = await Api(
        collection: "groups/${_groupModel.id}/members",
        doc: uid,
      ).getDocument();
      if(memberDoc.exists) {
        throw Exception("Member Sudah Ada");
      }
      final userDoc = await Api(collection: "users", doc: uid).getDocument();
      final userModel = UserModel.fromMap(userDoc.data() ?? {});
      await Api(
        collection: "groups/${_groupModel.id}/members",
        doc: uid,
      ).setDocument(userModel.toMapShort());
      await Api(
        collection: "users/$uid/groups",
        doc: _groupModel.id,
      ).setDocument(_groupModel.toMapShort());
    }
  }

  Future<void> changeAdminStatus(String uid, bool newIsAdmin) async {
    if (isAdmin) {
      await Api(
        collection: "groups/${_groupModel.id}/members",
        doc: uid,
      ).updateDocument({'isAdmin': newIsAdmin});
    }
  }

  Future<void> kickMember(String uid) async {
    if (isAdmin) {
      await Api(
        collection: "groups/${_groupModel.id}/members",
        doc: uid,
      ).deleteDocument();
      await Api(collection: "users/$uid/groups", doc: _groupModel.id)
          .deleteDocument();
    }
  }

  bool get isAdmin => _isAdmin;

  set isAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  set messageText(String value) {
    _messageText = value;
    notifyListeners();
  }

  set groupModel(GroupModel value) {
    if (_groupModel.id != value.id) {
      _messageText = "";
    }
    _groupModel = value;
    api.collection = "groups/${value.id}/messages";

    notifyListeners();
  }

  GroupModel get groupModel => _groupModel;

  String get groupId => _groupModel.id;

  String get title => _groupModel.title;

  String get image => _groupModel.image;

  String get messageText => _messageText;
}