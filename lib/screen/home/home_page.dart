import 'package:flutter/material.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/screen/friend/friend_page.dart';
import 'package:kadai_app/screen/issue/issue_page.dart';
import 'package:kadai_app/screen/setting/setting_page.dart';
import 'package:kadai_app/until/dialogs.dart';

class HomePage extends StatefulWidget {
  final UserData myData;
  final ValueChanged<UserData> updateMyData;

  const HomePage({Key key, this.myData, this.updateMyData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Dialogs().showExitDialog(context),
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            IssueScreen(
                myData: widget.myData, updateMyData: widget.updateMyData),
            FriendScreen(
                myData: widget.myData, updateMyData: widget.updateMyData),
            SettingScreen(
                myData: widget.myData, updateMyData: widget.updateMyData),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.white,
          elevation: 20,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.question_answer_rounded,
              ),
              label: 'Issue',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              label: 'List Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
              ),
              label: 'Setting',
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }
}
