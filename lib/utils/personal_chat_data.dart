import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/api.dart';
import 'package:messaging_app_update/model/user_model.dart';

class PersonalChatData extends ChangeNotifier {
  UserModel _friendModel = UserModel.initial();
  bool loading = false;

  final Api _currentUserApi = Api(collection: "");
  final Api _globalUserApi = Api(collection: "users");
  final Api _friendApi = Api(collection: "");
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserPersonalChats() {
    final user = _auth.currentUser;
    if (user != null) {
      return _currentUserApi.streamCollection();
    } else {
      throw Exception("Gagal Menerima Daftar Personal Chat");
    }
  }
  Future<Map<String, dynamic>> getPersonalChat(String uid) async {
    return await Api(collection: "groups", doc: uid).getDocument().then((value) => value.data()??{});
  }

  void markAsLoading() {
    loading = true;
    notifyListeners();
  }

  Future<bool> getFriendFromEmail(String email) async {
    markAsLoading();
    email = email.toLowerCase();
    final friendData = await _globalUserApi.searchDocument('email', email);

    final friend = friendData.docs.toList();
    if (friend.isEmpty) {
      friendModel = UserModel.initial();
      loading = false;
      notifyListeners();
      return false;
    } else if (friend[0].data()['uid'] == _auth.currentUser!.uid) {
      friendModel = UserModel.initial();
      loading = false;
      notifyListeners();
      return false;
    } else {
      friendModel = UserModel.fromMap(friend[0].data());
      loading = false;
      notifyListeners();
      return true;
    }
  }

  // Future<void> loadFriendFromId(String uid) async {
  //   _globalUserApi.doc = uid;
  //   friendModel = UserModel.fromMap(
  //     await _globalUserApi.getDocument().then(
  //           (value) => value.data() ?? {},
  //         ),
  //   );
  // }
  //
  // Future<String> gotoPersonalChat() async{
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     markAsLoading();
  //     _globalUserApi.doc = user.uid;
  //     _friendApi.doc = user.uid;
  //     _currentUserApi.doc = friendModel.uid;
  //     final personalChat = await _currentUserApi.getDocument();
  //     if (personalChat.exists) {
  //       loading = false;
  //       notifyListeners();
  //       return personalChat['id'];
  //     }
  //     final userDoc = await _globalUserApi.getDocument();
  //     final userModel = UserModel.fromMap(userDoc.data() ?? {});
  //     final pcId = await Api(collection: "groups").addDocumentWithId({
  //       'type': 2,
  //     });
  //     await _friendApi.setDocument(
  //       userModel.toMapShort()..addAll({'id': pcId}),
  //     );
  //     await _currentUserApi.setDocument(
  //       friendModel.toMapShort()..addAll({'id': pcId}),
  //     );
  //     final memberApi = Api(collection: "groups/$pcId/members");
  //     memberApi.doc = userModel.uid;
  //     await memberApi.setDocument(userModel.toMapShort());
  //     memberApi.doc = friendModel.uid;
  //     await memberApi.setDocument(friendModel.toMapShort());
  //     _friendModel = UserModel.initial();
  //     loading = false;
  //     notifyListeners();
  //     return pcId;
  //   }
  //   throw Exception("Belum Login");
  // }

  Future<void> createPersonalChat() async {
    markAsLoading();
    final user = _auth.currentUser;
    if (user != null) {
      _globalUserApi.doc = user.uid;
      _friendApi.doc = user.uid;
      _currentUserApi.doc = friendModel.uid;
      final personalChat = await _currentUserApi.getDocument();
      if (personalChat.exists) {
        loading = false;
        notifyListeners();
        throw Exception(personalChat['id']);
      }
      final userDoc = await _globalUserApi.getDocument();
      final userModel = UserModel.fromMap(userDoc.data() ?? {});
      final pcId = await Api(collection: "groups").addDocumentWithId({
        'type': 2,
      });
      await _friendApi.setDocument(
        userModel.toMapShort()..addAll({'id': pcId}),
      );
      await _currentUserApi.setDocument(
        friendModel.toMapShort()..addAll({'id': pcId}),
      );
      final memberApi = Api(collection: "groups/$pcId/members");
      memberApi.doc = userModel.uid;
      await memberApi.setDocument(userModel.toMapShort());
      memberApi.doc = friendModel.uid;
      await memberApi.setDocument(friendModel.toMapShort());
      _friendModel = UserModel.initial();
    }
    loading = false;
    notifyListeners();
  }

  clearModel() {
    _friendModel = UserModel.initial();
  }

  loadUser() {
    _currentUserApi.collection =
        "users/${_auth.currentUser!.uid}/personalChats";
  }

  UserModel get friendModel => _friendModel;

  set friendModel(UserModel value) {
    _friendModel = value;
    _friendApi.collection = "users/${value.uid}/personalChats";
    notifyListeners();
  }
}