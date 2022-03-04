class UserData {
  String email;
  String imageUrl;
  String name;
  List<String> myLikeList;
  List<String> myCommentList;

  UserData({
    this.email,
    this.imageUrl,
    this.name,
    this.myLikeList,
    this.myCommentList,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': this.email,
      'imageUrl': this.imageUrl,
      'name': this.name,
      'myLikeList': this.myLikeList,
      'myCommentList': this.myCommentList,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      name: map['name'] as String,
      myLikeList: map['myLikeList'] as List<String>,
      myCommentList: map['myCommentList'] as List<String>,
    );
  }
}
