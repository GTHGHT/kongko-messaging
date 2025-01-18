class GroupModel {
  String id;
  String title;
  String image;
  String? desc;

  GroupModel({
    required this.id,
    required this.title,
    required this.image,
    this.desc,
  });

  factory GroupModel.fromMap(Map<String, dynamic> data) {
    return GroupModel(
      id: data['id'],
      title: data['title'],
      image: data['image'] ?? "default_group.png",
    );
  }

  Map<String, dynamic> toMap(){
    final groupMap =  {
      'id': id,
      'type': 1,
      'title': title,
      'image': image.isEmpty ? "default_profile.png": image,
    };
    if ((desc??"").isNotEmpty){
      groupMap['desc'] = desc ?? "";
    }
    return groupMap;
  }

  Map<String, dynamic> toMapShort(){
    return {
      'id': id,
      'title': title,
      'image': image.isEmpty ? "default_profile.png": image,
    };
  }

  factory GroupModel.initial() {
    return GroupModel(
      id: '',
      title: '',
      image: '',
    );
  }
}