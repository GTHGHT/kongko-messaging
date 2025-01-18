class MemberModel{
  final String uid;
  final String username;
  final String image;
  final String email;

  MemberModel({
    required this.uid,
    required this.username,
    required this.image,
    required this.email,
  });

  factory MemberModel.fromMap(Map<String, dynamic> data){
    return MemberModel(
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

  factory MemberModel.initial() {
    return MemberModel(
      uid: '',
      username: '',
      image: '',
      email: '',
    );
  }
}