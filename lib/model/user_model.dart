class UserModel{
  final String uid;
  String username;
  String image;
  String email;

  UserModel({
    required this.uid,
    required this.username,
    required this.image,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> data){
    return UserModel(
      uid: data['uid'],
      username: data['username'],
      image: data['image'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'username': username,
      'image': image,
      'email': email,
    };
  }

  Map<String, dynamic> toMapShort(){
    return {
      'uid': uid,
      'username': username,
      'image': image,
    };
  }

  factory UserModel.initial() {
    return UserModel(
      uid: '',
      username: '',
      image: '',
      email: '',
    );
  }
}