import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'image_editor_pro.dart';

class QuestionImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;

  const QuestionImage({Key key, this.onFileChanged}) : super(key: key);

  @override
  _QuestionImageState createState() => _QuestionImageState();
}

class _QuestionImageState extends State<QuestionImage> {
  final ImagePicker _picker = ImagePicker();
  String imageUrl;
  File _defaultImage;
  File _video;
  File _cameraVideo;

  // This function will helps you to pick a Video File
  _pickVideo() async {
    final XFile video = await _picker.pickVideo(source: ImageSource.gallery);

    _video = File(video.path);
  }

  // This function will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    final XFile video = await _picker.pickVideo(source: ImageSource.camera);

    _cameraVideo = File(video.path);
    print('Link url video:-----' + _cameraVideo.path);
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Camera'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      }),
                  ListTile(
                      leading: const Icon(Icons.filter),
                      title: const Text('Pick file image'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.gallery);
                      }),
                  ListTile(
                      leading: const Icon(Icons.video_collection_outlined),
                      title: const Text('Pick file video'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickVideo();
                      }),
                  ListTile(
                      leading: const Icon(Icons.video_collection),
                      title: const Text('Video'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickVideoFromCamera();
                      }),
                ],
              ),
              onClosing: () {},
            ));
  }

  Future _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }

    var file = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));
    if (file == null) {
      return;
    }

    file = await compressImagePath(file.path, 35);

    setState(() {
      _defaultImage = file;
    });

    await _uploadFile(file.path);
  }

  Future<File> compressImagePath(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    print("NEED_URL: -----" + result.toString());

    return result;
  }

  Future _uploadFile(String path) async {
    final ref = storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toIso8601String() + p.basename(path));

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    setState(() {
      imageUrl = fileUrl;
    });

    widget.onFileChanged(fileUrl);
  }

  Future<void> getImageEditor() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ImageEditorPro(
            appBarColor: Colors.black87,
            bottomBarColor: Colors.black87,
            pathSave: null,
            defaultPathImage: _defaultImage == null ? '' : _defaultImage.path,
            isShowingChooseImage: false,
            isShowingFlip: false,
            isShowingRotate: false,
            isShowingBlur: false,
            isShowingFilter: false,
            isShowingEmoji: false,
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _defaultImage = value;
        });
      }
    }).catchError((er) {
      print(er);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (imageUrl == null)
        //   const Icon(Icons.image, size: 60, color: Colors.black45),
        // if (imageUrl != null)
        //   InkWell(
        //     splashColor: Colors.transparent,
        //     highlightColor: Colors.transparent,
        //     //onTap: () => _selectPhoto(),
        //     child: AppRoundImage.url(
        //       imageUrl,
        //       width: 80,
        //       height: 80,
        //     ),
        //   ),
        InkWell(
          onTap: () => _selectPhoto(),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(Icons.camera_alt,
                size: 30, color: Theme.of(context).primaryColor),
          ),
        ),
        ElevatedButton(
          child: const Text('Open Editor'),
          onPressed: () {
            getImageEditor();
          },
        ),
      ],
    );
  }
}
