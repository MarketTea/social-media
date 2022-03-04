class Question {
  String content;
  String imageUrl;
  String postId;
  int postTimeStamp;
  String title;
  String userName;
  String userThumbnail;

//<editor-fold desc="Data Methods">

  Question({
    this.content,
    this.imageUrl,
    this.postId,
    this.postTimeStamp,
    this.title,
    this.userName,
    this.userThumbnail,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'imageUrl': imageUrl,
      'postId': postId,
      'postTimeStamp': postTimeStamp,
      'title': title,
      'userName': userName,
      'userThumbnail': userThumbnail,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      content: map['content'] as String,
      imageUrl: map['imageUrl'] as String,
      postId: map['postId'] as String,
      postTimeStamp: map['postTimeStamp'] as int,
      title: map['title'] as String,
      userName: map['userName'] as String,
      userThumbnail: map['userThumbnail'] as String,
    );
  }

//</editor-fold>
}
