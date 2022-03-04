import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/constants/consts.dart';

class FirebaseCloudStore {
  static Future<void> commentToPost(
      String toUserID,
      String toCommentID,
      String postId,
      String commentContent,
      UserData userProfile) async {
    String commentID = Constants.getRandomString(8) + Random().nextInt(500).toString();

    Map<String, dynamic> dataQuestion = {
      'toUserID': toUserID,
      'toCommentID': toCommentID,
      'commentID': commentID,
      'userName': userProfile.name,
      'imageUrl': userProfile.imageUrl,
      'commentTimeStamp': DateTime.now().millisecondsSinceEpoch,
      'commentContent': commentContent,
    };

    FirebaseFirestore.instance
        .collection('question')
        .doc(postId)
        .collection('comment')
        .doc(commentID)
        .set(dataQuestion);
  }

  static Future<void> updatePostCommentCount(
    DocumentSnapshot postData,
  ) async {
    postData.reference.update({'postCommentCount': FieldValue.increment(1)});
  }
}
