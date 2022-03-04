import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/model/user.dart';
import '../constants/consts.dart';

class CommentItem extends StatefulWidget {
  final DocumentSnapshot data;
  final UserData myData;
  final Size size;
  final ValueChanged<UserData> updateMyDataToMain;
  final ValueChanged<List<String>> replyComment;

  const CommentItem(
      {Key key,
      this.data,
      this.myData,
      this.size,
      this.updateMyDataToMain,
      this.replyComment})
      : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  UserData _currentMyData;

  @override
  void initState() {
    _currentMyData = widget.myData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(6.0, 2.0, 10.0, 2.0),
                child: Icon(
                  Icons.supervised_user_circle,
                  size: 40,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                widget.data['userName'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  widget.data['commentContent'],
                                  maxLines: null,
                                )),
                          ],
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15.0)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: SizedBox(
                        width: widget.size.width * 0.38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(Constants.readTimestamp(
                                widget.data['commentTimeStamp'])),
                            GestureDetector(
                                onTap: () {},
                                child: Text('Like',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]))),
                            GestureDetector(
                                onTap: () {
                                  widget.replyComment([
                                    widget.data['userName'],
                                    widget.data['commentID'],
                                  ]);
                                  print('leave comment of comment');
                                },
                                child: Text('Reply',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
