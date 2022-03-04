import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/providers/auth_provider.dart';
import 'package:kadai_app/until/router.dart';
import 'package:kadai_app/until/toast_login.dart';
import 'package:kadai_app/widgets/button_login.dart';
import 'package:kadai_app/widgets/loading_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var loading = false;
  UserData myData;

  Future<void> _logInWithFacebook() async {
    setState(() {
      loading = true;
    });

    try {
      final facebookLoginResult = await FacebookAuth.instance.login();
      final userData = await FacebookAuth.instance.getUserData();
      var name = userData['name'];
      var imageUrl = userData['picture']['data']['url'];
      var email = userData['email'];
      var userId = facebookLoginResult.accessToken.token;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_id', userId);

      setState(() {
        myData = UserData(
          email: email,
          imageUrl: imageUrl,
          name: name,
          myLikeList: prefs.getStringList('likeList'),
          myCommentList: prefs.getStringList('commentList'),
        );
      });

      final facebookAuthCredential = FacebookAuthProvider.credential(
          facebookLoginResult.accessToken.token);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      await FirebaseFirestore.instance.collection('users').add({
        'email': userData['email'],
        'imageUrl': userData['picture']['data']['url'],
        'name': userData['name'],
      });

      MyRouter.pushPageReplacement(
        context,
        HomePage(myData: myData, updateMyData: updateMyData),
      );
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exists with a different sign in provider';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred';
          break;
        case 'operation-not-allowed':
          content = 'This operation is not allowed';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found';
          break;
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Log in with facebook failed'),
                content: Text(content),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ok'))
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _logInWithGoogle() async {
    setState(() {
      loading = true;
    });

    final googleSignIn = GoogleSignIn(scopes: ['email']);

    try {
      final googleSignInAccount = await googleSignIn.signIn();
      var emailGg = googleSignInAccount.email;
      var imageUrlGg = googleSignInAccount.photoUrl;
      var nameGg = googleSignInAccount.displayName;

      if (googleSignInAccount == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        myData = UserData(
          email: emailGg,
          imageUrl: imageUrlGg,
          name: nameGg,
          myLikeList: prefs.getStringList('likeList'),
          myCommentList: prefs.getStringList('commentList'),
        );
      });

      final googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseFirestore.instance.collection('users').add({
        'email': googleSignInAccount.email,
        'imageUrl': googleSignInAccount.photoUrl,
        'name': googleSignInAccount.displayName,
      });

      MyRouter.pushPageReplacement(
        context,
        HomePage(
          myData: myData,
          updateMyData: updateMyData,
        ),
      );
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exists with a different sign in provider';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred';
          break;
        case 'operation-not-allowed':
          content = 'This operation is not allowed';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found';
          break;
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Log in with facebook failed'),
                content: Text(content),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ok'))
                ],
              ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void updateMyData(UserData newMyData) {
    setState(() {
      myData = newMyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        ShowToast.showToastLogin("Sign in fail");
        break;
      case Status.authenticateCanceled:
        ShowToast.showToastLogin("Sign in canceled");
        break;
      case Status.authenticated:
        ShowToast.showToastLogin("Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/light-1.png'))),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage('assets/images/light-2.png'))),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/clock.png'))),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loading) ...[
                      const SizedBox(height: 15),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (!loading) ...[
                      Button(
                        text: 'Login with email',
                        color: Colors.grey.shade600,
                        image: const AssetImage('assets/images/email.png'),
                        onPressed: () {
                          ShowToast.showToastLogin('Log in with Email');
                        },
                      ),
                      Button(
                        text: 'Login with Facebook',
                        color: Colors.blue,
                        image: const AssetImage('assets/images/facebook.png'),
                        onPressed: () {
                          //Provider.of<FacebookSignInController>(context, listen: false).login();
                          //_logInWithFacebook();
                          ShowToast.showToastLogin('Log in with Facebook');
                        },
                      ),
                      Button(
                        text: 'Login with Google',
                        color: Colors.green,
                        image: const AssetImage('assets/images/google.png'),
                        onPressed: () async {
                          bool isSuccess = await authProvider.handleSignIn();
                          if (isSuccess) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Positioned(
                        child: authProvider.status == Status.authenticating ? const LoadingView() : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
    //_checkUserLogin();
  }

  void _checkUserLogin() async {
    String userId;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id' ?? '');
    });

    if (userId.isNotEmpty) {
      print('CHECK USER LOGIN ------ HOME');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return const HomePage();
        },
      ));
    } else {
      print('CHECK USER LOGIN ------ Login');
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ));
    }
  }
}
