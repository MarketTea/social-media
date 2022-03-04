import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/constants/firestore_constants.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/providers/auth_provider.dart';
import 'package:kadai_app/providers/firebase_cloud_store.dart';
import 'package:kadai_app/screen/question/question_page.dart';
import '../../constants/consts.dart';
import 'package:kadai_app/widgets/comment_item.dart';
import 'package:kadai_app/widgets/issue_item.dart';
import 'package:provider/src/provider.dart';

class CommentScreen extends StatefulWidget {
  final DocumentSnapshot postData;
  final UserData myData;
  final ValueChanged<UserData> updateMyData;

  const CommentScreen({Key key, this.myData, this.updateMyData, this.postData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentScreen();
}

class _CommentScreen extends State<CommentScreen> {
  final TextEditingController _msgTextController = TextEditingController();
  UserData currentMyData;
  String _replyUserID;
  String _replyCommentID;
  String _replyUserFCMToken;
  final FocusNode _writingTextFocus = FocusNode();
  String commentID =
      Constants.getRandomString(8) + Random().nextInt(500).toString();
  AuthProvider authProvider;

  String nickname = '';
  String photoUrl = '';

  void readLocal() {
    setState(() {
      nickname = authProvider.getPref(FirestoreConstants.nickname) ?? "";
      photoUrl = authProvider.getPref(FirestoreConstants.photoUrl) ?? "";
    });
  }


  @override
  void initState() {
    currentMyData = widget.myData;
    _msgTextController.addListener(_msgTextControllerListener);
    authProvider = context.read<AuthProvider>();
    readLocal();
    super.initState();
  }

  void _msgTextControllerListener() {
    if (_msgTextController.text.isEmpty ||
        _msgTextController.text.split(" ")[0] != _replyUserID) {
      _replyUserID = null;
      _replyCommentID = null;
      _replyUserFCMToken = null;
    }
  }

  void _replyComment(List<String> commentData) async {
    //String replyTo,String replyCommentID,String replyUserToken) async {
    _replyUserID = commentData[0];
    _replyCommentID = commentData[1];
    FocusScope.of(context).requestFocus(_writingTextFocus);
    _msgTextController.text = '${commentData[0]} ';
  }

  void _moveToFullImage() => Navigator.push(
      context, MaterialPageRoute(builder: (context) => const QuestionPage()));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comment Detail'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('question')
                .doc(widget.postData['postId'])
                .collection('comment')
                .orderBy('commentTimeStamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                IssueItem(
                                  data: widget.postData,
                                  myData: widget.myData,
                                  updateMyDataToMain: widget.updateMyData,
                                  threadItemAction: _moveToFullImage,
                                  isFromThread: false,
                                  commentCount: snapshot.data.docs.length,
                                  parentContext: context,
                                ),
                                snapshot.data.docs.isNotEmpty
                                    ? ListView(
                                        primary: false,
                                        shrinkWrap: true,
                                        children:
                                            snapshot.data.docs.map((document) {
                                          return CommentItem(
                                              data: document,
                                              myData: widget.myData,
                                              size: size,
                                              updateMyDataToMain:
                                                  widget.updateMyData,
                                              replyComment: _replyComment);
                                        }).toList(),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildTextComposer()
                ],
              );
            }));
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                focusNode: _writingTextFocus,
                controller: _msgTextController,
                decoration: const InputDecoration.collapsed(
                    hintText: "Write a comment"),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    Map<String, dynamic> dataQuestion = {
                      'toUserID': widget.postData['userName'],
                      'commentID': commentID,
                      'userName': nickname,
                      'imageUrl': photoUrl,
                      'commentTimeStamp': DateTime.now().millisecondsSinceEpoch,
                      'commentContent': _msgTextController.text,
                    };

                    FirebaseFirestore.instance
                        .collection('question')
                        .doc(widget.postData['postId'])
                        .collection('comment')
                        .doc(commentID)
                        .set(dataQuestion);

                    _msgTextController.text = '';
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    try {
      await FirebaseCloudStore.commentToPost(
          _replyUserID ?? widget.postData['userName'],
          _replyCommentID ?? widget.postData['commentID'],
          widget.postData['postId'],
          _msgTextController.text,
          widget.myData);
      await FirebaseCloudStore.updatePostCommentCount(widget.postData);
      FocusScope.of(context).requestFocus(FocusNode());
      _msgTextController.text = '';
    } catch (e) {
      print('error to submit comment');
    }
  }
}
