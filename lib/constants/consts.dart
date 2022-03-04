import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Constants {
  //App related strings
  static String appName = 'Kadai';
  static String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));

  static String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      if (diff.inHours > 0) {
        time = diff.inHours.toString() + 'h';
      } else if (diff.inMinutes > 0) {
        time = diff.inMinutes.toString() + 'm';
      } else if (diff.inSeconds > 0) {
        time = 'now';
      } else if (diff.inMilliseconds > 0) {
        time = 'now';
      } else if (diff.inMicroseconds > 0) {
        time = 'now';
      } else {
        time = 'now';
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      time = diff.inDays.toString() + 'd';
    } else if (diff.inDays > 6) {
      time = (diff.inDays / 7).floor().toString() + 'w';
    } else if (diff.inDays > 29) {
      time = (diff.inDays / 30).floor().toString() + 'm';
    } else if (diff.inDays > 365) {
      time = '${date.month} ${date.day}, ${date.year}';
    }
    return time;
  }

  static Widget loadingCircle(bool isLoading) {
    return isLoading
        ? Positioned(
      child: Container(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        color: Colors.white.withOpacity(0.7),
      ),
    )
        : Container();
  }

  static List<DocumentSnapshot> sortDocumentsByComment(List<DocumentSnapshot> data) {
    List<DocumentSnapshot> _originalData = data;
    Map<String, List<DocumentSnapshot>> commentDocuments = Map<String, List<DocumentSnapshot>>();
    List<int> replyCommentIndex = List<int>();
    for (int i = 0; i < _originalData.length; i++) {
      for (int j = 0; j < _originalData.length; j++) {
        if (_originalData[i]['commentID'] == _originalData[j]['toCommentID']) {
          List<DocumentSnapshot> savedCommentData;
          if (commentDocuments[_originalData[i]['commentID']] != null &&
              commentDocuments[_originalData[i]['commentID']].length > 0) {
            savedCommentData = commentDocuments[_originalData[i]['commentID']];
          } else {
            savedCommentData = List<DocumentSnapshot>();
          }
          savedCommentData.add(_originalData[j]);
          commentDocuments[_originalData[i]['commentID']] = savedCommentData;
          replyCommentIndex.add(j);
        }
      }
    }

    replyCommentIndex.sort((a, b) {
      return b.compareTo(a);
    });

    // remove comment
    if (replyCommentIndex.length > 0) {
      for (int i = 0; i < replyCommentIndex.length; i++) {
        _originalData.removeAt(replyCommentIndex[i]);
      }
    }

    // Add list to comment
    for (int i = 0; i < _originalData.length; i++) {
      if (commentDocuments[_originalData[i]['commentID']] != null) {
        _originalData.insertAll(
            i + 1, commentDocuments[_originalData[i]['commentID']]);
      }
    }
    return _originalData;
  }

  static String commentWithoutReplyUser(String commentString) {
    List<String> splitCommentString = commentString.split(' ');
    int commentUserNameLength = splitCommentString[0].length;
    String returnText =
    commentString.substring(commentUserNameLength, commentString.length);
    return returnText;
  }

}
