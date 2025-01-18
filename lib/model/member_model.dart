import 'package:messaging_app_update/model/user_model.dart';

class MemberModel{
  String uid;
  String username;
  String image;
  bool isAdmin;

  MemberModel({
    required this.uid,
    required this.username,
    required this.image,
    required this.isAdmin,
  });

  factory MemberModel.initial() {
    return MemberModel(
      uid: "",
      username: "",
      image: "",
      isAdmin: false,
    );
  }

  factory MemberModel.fromMap(Map<String, dynamic> data) {
    return MemberModel(
      uid: data['uid'],
      username: data['username'],
      image: data['image'],
      isAdmin: data.containsKey('isAdmin') ? data['isAdmin'] : false,
    );
  }

  factory MemberModel.fromUserModel(UserModel model, bool isAdmin){
    return MemberModel(
      uid: model.uid,
      username: model.username,
      image:  model.image,
      isAdmin: isAdmin,
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'uid': uid,
      'username': username,
      'image': image,
      'isAdmin': isAdmin,
    };
  }
}