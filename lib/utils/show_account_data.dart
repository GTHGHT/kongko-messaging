import 'package:flutter/material.dart';
import 'package:messaging_app_update/model/user_model.dart';

import '../services/api.dart';

class ShowAccountData extends ChangeNotifier{
  UserModel _userModel = UserModel.initial();

  loadUserModel(String uid) async{
    final _currentUserDoc =
        await Api(collection: "users", doc: uid)
        .getDocument();
    _userModel =
        UserModel.fromMap(_currentUserDoc.data() as Map<String, dynamic>);
    notifyListeners();
  }

  UserModel get userModel => _userModel;

  set userModel(UserModel value) {
    _userModel = value;
    notifyListeners();
  }
}