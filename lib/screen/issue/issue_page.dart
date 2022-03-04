import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/screen/comment/comment_page.dart';
import 'package:kadai_app/screen/question/question_page.dart';
import 'package:kadai_app/until/router.dart';
import 'package:kadai_app/widgets/issue_item.dart';

class IssueScreen extends StatefulWidget {
  final UserData myData;
  final ValueChanged<UserData> updateMyData;

  const IssueScreen({Key key, this.myData, this.updateMyData})
      : super(key: key);

  @override
  _IssueScreenState createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Issue'),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('question').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot data) {
                    return IssueItem(
                      data: data,
                      myData: widget.myData,
                      updateMyDataToMain: widget.updateMyData,
                      threadItemAction: _moveToContentDetail,
                      isFromThread: true,
                      commentCount: data['postCommentCount'],
                      parentContext: context,
                    );
                  }).toList(),
                );
              }
            }),
        floatingActionButton: FloatingActionButton(
            elevation: 8.0,
            child: const Icon(Icons.add),
            onPressed: () {
              MyRouter.pushPage(context, QuestionPage(myData: widget.myData));
            }));
  }

  void _moveToContentDetail(DocumentSnapshot data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CommentScreen(
                  postData: data,
                  myData: widget.myData,
                  updateMyData: widget.updateMyData,
                )));
  }
}
