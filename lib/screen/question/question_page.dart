import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:kadai_app/constants/firestore_constants.dart';
import 'package:kadai_app/model/user.dart';
import 'package:kadai_app/providers/auth_provider.dart';
import 'package:kadai_app/providers/tag_state.dart';
import 'package:kadai_app/constants/consts.dart';
import 'package:kadai_app/widgets/question_image.dart';
import 'package:provider/provider.dart';

class QuestionPage extends StatefulWidget {
  final UserData myData;

  const QuestionPage({Key key, this.myData}) : super(key: key);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String imageUrl = '';
  String postId =
      Constants.getRandomString(8) + Random().nextInt(500).toString();

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthProvider authProvider;

  String nickname = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      nickname = authProvider.getPref(FirestoreConstants.nickname) ?? "";
      photoUrl = authProvider.getPref(FirestoreConstants.photoUrl) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Ask Question')),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty ? 'Title is require' : null;
                    },
                    controller: titleController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        suffixIcon: titleController.text.isEmpty
                            ? const Text('')
                            : GestureDetector(
                                onTap: () {
                                  titleController.clear();
                                },
                                child: const Icon(Icons.close)),
                        hintText: 'Enter title',
                        labelText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1))),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      QuestionImage(onFileChanged: (imageUrl) {
                        setState(() {
                          this.imageUrl = imageUrl;
                          print("NEED_URL: -----" + imageUrl);
                        });
                      }),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Flexible(
                        flex: 12,
                        child: TextFormField(
                          validator: (val) {
                            return val.isEmpty ? 'Body is require' : null;
                          },
                          maxLines: 6,
                          controller: bodyController,
                          onChanged: (value) {
                            print(value);
                          },
                          decoration: InputDecoration(
                              suffixIcon: bodyController.text.isEmpty
                                  ? const Text('')
                                  : GestureDetector(
                                      onTap: () {
                                        bodyController.clear();
                                      },
                                      child: const Icon(Icons.close)),
                              hintText: 'Enter body',
                              labelText: 'Body',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  tagFiled(context),
                  const SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                          40), // fromHeight use double.infinity as width and 40 is the height
                    ),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Question')),
                        );

                        Map<String, dynamic> dataQuestion = {
                          "title": titleController.text,
                          "content": bodyController.text,
                          "imageUrl": imageUrl,
                          "userName": nickname,
                          'userThumbnail': photoUrl,
                          'postTimeStamp':
                              DateTime.now().millisecondsSinceEpoch,
                          'postId': postId,
                          'postCommentCount' : 0,
                        };

                        FirebaseFirestore.instance
                            .collection('question')
                            .doc(postId)
                            .set(dataQuestion);

                        titleController.text = "";
                        bodyController.text = "";
                      }
                    },
                    child: const Text('Post your question'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget tagFiled(BuildContext context) {
    var suggestTag = [
      "Java",
      "Android",
      "Flutter",
      "Javascript",
      "React Native",
      "React JS",
      "Python",
      "html"
          "css",
      "golang",
      "Dart",
      "Mongo DB"
    ];

    final controller = Get.put(TagStateController());
    final textController = TextEditingController();

    return Column(
      children: [
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
              controller: textController,
              onEditingComplete: () {
                controller.listTag.add(textController.text);
                textController.clear();
              },
              autofocus: false,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: 16, fontStyle: FontStyle.italic),
              decoration: InputDecoration(
                  hintText: 'Enter Tag',
                  labelText: 'Tag',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1)))),
          onSuggestionSelected: (String suggestion) {
            controller.listTag.add(suggestion);
          },
          itemBuilder: (BuildContext context, String itemData) {
            return ListTile(
              leading: const Icon(Icons.tag),
              title: Text(itemData),
            );
          },
          suggestionsCallback: (String pattern) {
            return suggestTag.where((element) =>
                element.toLowerCase().contains(pattern.toLowerCase()));
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() => controller.listTag.isEmpty
            ? const Center(
                child: Text('No tag selected'),
              )
            : Wrap(
                children: controller.listTag
                    .map((element) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Chip(
                            label: Text(element),
                            deleteIcon: const Icon(Icons.clear),
                            onDeleted: () => controller.listTag.remove(element),
                          ),
                        ))
                    .toList()))
      ],
    );
  }
}
