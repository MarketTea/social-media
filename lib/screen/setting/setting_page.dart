import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kadai_app/model/user.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

import 'package:firebase_storage/firebase_storage.dart' as storage;

class SettingScreen extends StatefulWidget {
  final UserData myData;
  final ValueChanged<UserData> updateMyData;
  final Function(String videoUrl) onFileChanged;

  const SettingScreen(
      {Key key, this.myData, this.updateMyData, this.onFileChanged})
      : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  File _image;
  File _cameraImage;
  File _video;
  File _cameraVideo;

  ImagePicker picker = ImagePicker();

  VideoPlayerController _videoPlayerController;
  VideoPlayerController _cameraVideoPlayerController;

  // This function will helps you to pick a Video File
  _pickVideo() async {
    XFile pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    _video = File(pickedFile.path);

    _videoPlayerController = VideoPlayerController.file(_video)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });

    await _uploadFile(_video.path);
  }

  // This function will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    XFile pickedFile = await picker.pickVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile.path);

    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.play();
      });

    await _uploadFile(_cameraVideo.path);
  }

  Future _uploadFile(String path) async {
    final ref = storage.FirebaseStorage.instance
        .ref()
        .child('videos')
        .child(DateTime.now().toIso8601String() + p.basename(path));

    final result = await ref.putFile(File(path));
    final fileVideoUrl = await result.ref.getDownloadURL();

    widget.onFileChanged(fileVideoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image / Video Picker"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (_video != null)
                  _videoPlayerController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController),
                        )
                      : Container()
                else
                  const Text(
                    "Click on Pick Video to select video",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _pickVideo();
                  },
                  child: const Text("Pick Video From Gallery"),
                ),
                if (_cameraVideo != null)
                  _cameraVideoPlayerController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio:
                              _cameraVideoPlayerController.value.aspectRatio,
                          child: VideoPlayer(_cameraVideoPlayerController),
                        )
                      : Container()
                else
                  const Text(
                    "Click on Pick Video to select video",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ElevatedButton(
                  onPressed: () {
                    _pickVideoFromCamera();
                  },
                  child: const Text("Pick Video From Camera"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
