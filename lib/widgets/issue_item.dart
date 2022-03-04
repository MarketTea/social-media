import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/constants/consts.dart';
import 'package:kadai_app/widgets/video_items.dart';
import 'package:video_player/video_player.dart';

class IssueItem extends StatefulWidget {
  final BuildContext parentContext;
  final DocumentSnapshot data;
  final UserData myData;
  final ValueChanged<UserData> updateMyDataToMain;
  final bool isFromThread;
  final Function threadItemAction;
  final int commentCount;

  const IssueItem(
      {Key key,
      this.parentContext,
      this.data,
      this.myData,
      this.updateMyDataToMain,
      this.isFromThread,
      this.threadItemAction,
      this.commentCount})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _IssueItem();
}

class _IssueItem extends State<IssueItem> {
  UserData _currentMyData;
  int _likeCount;

  @override
  void initState() {
    _currentMyData = widget.myData;
    //_likeCount = widget.data['postLikeCount'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.supervised_user_circle, size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.data['userName'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            Constants.readTimestamp(
                                widget.data['postTimeStamp']),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                                child: Icon(Icons.report),
                              ),
                              Text("Report"),
                            ],
                          ),
                        ),
                      ],
                      initialValue: 1,
                      onCanceled: () {
                        print("You have canceled the menu.");
                      },
                      onSelected: (value) {},
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.isFromThread
                    ? widget.threadItemAction(widget.data)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    (widget.data['title'] as String).length > 200
                        ? '${widget.data['title'].substring(0, 132)} ...'
                        : widget.data['title'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => widget.isFromThread
                    ? widget.threadItemAction(widget.data)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    (widget.data['content'] as String).length > 200
                        ? '${widget.data['content'].substring(0, 132)} ...'
                        : widget.data['content'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              if ((widget.data['imageUrl'] as String).isEmpty)
                VideoItems(
                  videoPlayerController: VideoPlayerController.network(widget.data['videoUrl']),
                  looping: false,
                  autoplay: false,
                ),
              if ((widget.data['imageUrl'] as String).isNotEmpty)
                Container(
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(widget.data['imageUrl']),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              const Divider(
                height: 2,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.thumb_up,
                              size: 18,
                              color: Colors.black),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Like',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.isFromThread
                          ? widget.threadItemAction(widget.data)
                          : null,
                      child: Row(
                        children: const <Widget>[
                          Icon(Icons.mode_comment, size: 18),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Comment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
