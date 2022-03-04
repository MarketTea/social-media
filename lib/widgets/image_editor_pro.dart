import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kadai_app/screen/editor/all_emojies.dart';
import 'package:kadai_app/screen/editor/bottombar_container.dart';
import 'package:kadai_app/screen/editor/color_filter_generator.dart';
import 'package:kadai_app/screen/editor/colors_picker.dart';
import 'package:kadai_app/screen/editor/emoji.dart';
import 'package:kadai_app/screen/editor/sliders.dart';
import 'package:kadai_app/screen/editor/text_add_edit.dart';
import 'package:kadai_app/screen/editor/text_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart' as p;

var width = 300;
var height = 300;
var slider = 0.0;
var howMuchWidget = 0;
List<Map> widgetJson = [];
SignatureController _controller =
    SignatureController(penStrokeWidth: 5, penColor: Colors.green);

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;
  final Directory pathSave;
  final double pixelRatio;
  final String defaultPathImage;
  final bool isShowingChooseImage;
  final bool isShowingBrush;
  final bool isShowingText;
  final bool isShowingFlip;
  final bool isShowingRotate;
  final bool isShowingBlur;
  final bool isShowingEraser;
  final bool isShowingFilter;
  final bool isShowingEmoji;
  final Function(String imageUrl) onFileChanged;

  const ImageEditorPro({
    Key key,
    this.appBarColor,
    this.bottomBarColor,
    this.pathSave,
    this.pixelRatio,
    this.defaultPathImage,
    this.isShowingChooseImage = true,
    this.isShowingBrush = true,
    this.isShowingText = true,
    this.isShowingFlip = true,
    this.isShowingRotate = true,
    this.isShowingBlur = true,
    this.isShowingEraser = true,
    this.isShowingFilter = true,
    this.isShowingEmoji = true,
    this.onFileChanged
  }) : super(key: key);

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

class _ImageEditorProState extends State<ImageEditorPro> {
  // Create some values
  Color pickerColor = const Color(0xFF443A49);
  Color currentColor = const Color(0xFF443A49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller =
        SignatureController(penStrokeWidth: 5, penColor: color, points: points);
  }

  List<Offset> offsets = [];
  final globalState = GlobalKey<ScaffoldState>();
  List<Offset> _points = <Offset>[];
  List type = [];
  List alignment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();
  File _image;
  ScreenshotController screenshotController = ScreenshotController();
  Timer timePrediction;

  void timers() {
    Timer.periodic(const Duration(milliseconds: 10), (tim) {
      setState(() {});
      timePrediction = tim;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.defaultPathImage != null &&
          widget.defaultPathImage.isNotEmpty) {
        var fileImage = File(widget.defaultPathImage);
        if (fileImage.existsSync()) {
          final decodedImage =
              await decodeImageFromList(fileImage.readAsBytesSync());
          setState(() {
            width = decodedImage.width;
            height = decodedImage.height;
            _image = File(fileImage.path);
            _controller.clear();
          });
        }
      }
    });

    timers();
    _controller.clear();
    type.clear();
    offsets.clear();
    howMuchWidget = 0;
    super.initState();
  }

  @override
  void dispose() {
    timePrediction.cancel();
    _controller.clear();
    widgetJson.clear();
    super.dispose();
  }

  double flipValue = 0;
  int rotateValue = 0; // to rotate an object by 90 degrees follow clockwise
  double blurValue = 0;
  double opacityValue = 0;
  Color colorValue = Colors.transparent;

  double hueValue = 0;
  double brightnessValue = 0;
  double saturationValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalState,
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text('SAVE'),
            onPressed: () {
              screenshotController
                  .capture(pixelRatio: widget.pixelRatio ?? 1.5)
                  .then((binaryIntList) async {
                final paths = widget.pathSave ?? await getTemporaryDirectory();
                final file = await File(
                        '${paths.path}/' + DateTime.now().toString() + '.jpg')
                    .create();
                file.writeAsBytesSync(binaryIntList);
                _uploadFile(file.path);
                print("File save change:----- " + file.toString());
                Navigator.pop(context, file);
              }).catchError((onError) {
                print(onError);
              });
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
          ),
        ],
        backgroundColor: widget.appBarColor ?? Colors.black87,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBar: _buildWidgetListMenu(),
      body: Screenshot(
        controller: screenshotController,
        child: Center(
          child: RotatedBox(
            quarterTurns: rotateValue,
            child: imageFilterLatest(
              hue: hueValue,
              brightness: brightnessValue,
              saturation: saturationValue,
              child: Container(
                margin: const EdgeInsets.all(20),
                color: Colors.white,
                width: width.toDouble(),
                height: height.toDouble(),
                child: RepaintBoundary(
                  key: globalKey,
                  child: Stack(
                    children: [
                      _image != null
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(flipValue),
                              child: ClipRect(
                                child: Container(
                                  width: width.toDouble(),
                                  height: height.toDouble(),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      alignment: Alignment.center,
                                      fit: BoxFit.fitHeight,
                                      image: FileImage(
                                        File(_image.path),
                                      ),
                                    ),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: blurValue,
                                      sigmaY: blurValue,
                                    ),
                                    child: Container(
                                      color:
                                          colorValue.withOpacity(opacityValue),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      GestureDetector(
                        onPanUpdate: (DragUpdateDetails details) {
                          setState(() {
                            RenderBox object =
                                context.findRenderObject() as RenderBox;
                            var _localPosition =
                                object.globalToLocal(details.globalPosition);
                            _points = List.from(_points)..add(_localPosition);
                          });
                        },
                        onPanEnd: (DragEndDetails details) {
                          _points.add(null);
                        },
                        child: Signat(),
                      ),
                      Stack(
                        children: widgetJson.asMap().entries.map((f) {
                          return type[f.key] == 1
                              ? EmojiView(
                                  left: offsets[f.key].dx,
                                  top: offsets[f.key].dy,
                                  onTap: () {
                                    globalState.currentState
                                        .showBottomSheet((context) {
                                      return Sliders(
                                        index: f.key,
                                        mapValue: f.value,
                                      );
                                    });
                                  },
                                  onUpdate: (details) {
                                    setState(() {
                                      offsets[f.key] = Offset(
                                          offsets[f.key].dx + details.delta.dx,
                                          offsets[f.key].dy + details.delta.dy);
                                    });
                                  },
                                  mapJson: f.value,
                                )
                              : type[f.key] == 2
                                  ? TextView(
                                      left: offsets[f.key].dx,
                                      top: offsets[f.key].dy,
                                      onTap: () {
                                        showModalBottomSheet(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                topLeft: Radius.circular(10),
                                              ),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return TextAddEdit(
                                                index: f.key,
                                                mapValue: f.value,
                                                isEdit: true,
                                              );
                                            });
                                      },
                                      onUpdate: (details) {
                                        setState(() {
                                          offsets[f.key] = Offset(
                                            offsets[f.key].dx +
                                                details.delta.dx,
                                            offsets[f.key].dy +
                                                details.delta.dy,
                                          );
                                        });
                                      },
                                      mapJson: f.value,
                                    )
                                  : Container();
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetListMenu() {
    final listMenu = <Widget>[];
    if (widget.isShowingBrush) {
      listMenu.add(
        BottomBarContainer(
          colors: widget.bottomBarColor,
          icons: Icons.brush,
          title: 'Brush',
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                        showLabel: true,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Got it'),
                        onPressed: () {
                          setState(() => currentColor = pickerColor);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
      );
    }

    if (widget.isShowingText) {
      listMenu.add(
        BottomBarContainer(
          title: 'Text',
          colors: widget.bottomBarColor,
          icons: Icons.text_fields,
          onTap: () async {
            type.add(2);
            final defaultText = {
              'name': 'Insert your message',
              'color': Colors.black,
              'size': 12.0,
              'align': TextAlign.left,
            };
            widgetJson.add(defaultText);
            offsets.add(Offset.zero);
            howMuchWidget++;
            var value = await showModalBottomSheet(
              context: context,
              builder: (context) {
                return TextAddEdit(
                  index: widgetJson.length - 1,
                  mapValue: defaultText,
                  isEdit: false,
                );
              },
            );
            if (value == null) {
              widgetJson.removeLast();
            }
          },
        ),
      );
    }

    if (widget.isShowingFlip) {
      listMenu.add(
        BottomBarContainer(
          title: 'Flip',
          colors: widget.bottomBarColor,
          icons: Icons.flip,
          onTap: () {
            setState(() {
              flipValue = flipValue == 0 ? math.pi : 0;
            });
          },
        ),
      );
    }

    if (widget.isShowingRotate) {
      listMenu.add(
        BottomBarContainer(
          title: 'Rotate Left',
          colors: widget.bottomBarColor,
          icons: Icons.rotate_left,
          onTap: () {
            setState(() {
              rotateValue--;
            });
          },
        ),
      );
      listMenu.add(
        BottomBarContainer(
            title: 'Rotate Right',
            colors: widget.bottomBarColor,
            icons: Icons.rotate_right,
            onTap: () {
              setState(() {
                rotateValue++;
              });
            }),
      );
    }

    if (widget.isShowingBlur) {
      listMenu.add(
        BottomBarContainer(
          title: 'Blur',
          colors: widget.bottomBarColor,
          icons: Icons.blur_on,
          onTap: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setS) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      height: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'Slider Filter Color'.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 20),
                          const Text(
                            'Slider Color',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: BarColorPicker(
                                  width: 300,
                                  thumbColor: Colors.white,
                                  cornerRadius: 10,
                                  pickMode: PickMode.Color,
                                  colorListener: (int value) {
                                    setS(() {
                                      setState(() {
                                        colorValue = Color(value);
                                      });
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    setS(() {
                                      colorValue = Colors.transparent;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Slider Blur',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.grey,
                                  value: blurValue,
                                  min: 0.0,
                                  max: 10.0,
                                  onChanged: (v) {
                                    setS(() {
                                      setState(() {
                                        blurValue = v;
                                      });
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setS(() {
                                    setState(() {
                                      blurValue = 0.0;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Slider Opacity',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.grey,
                                  value: opacityValue,
                                  min: 0.00,
                                  max: 1.0,
                                  onChanged: (v) {
                                    setS(() {
                                      setState(() {
                                        opacityValue = v;
                                      });
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setS(() {
                                    setState(() {
                                      opacityValue = 0.0;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      );
    }

    if (widget.isShowingEraser) {
      listMenu.add(
        BottomBarContainer(
          colors: widget.bottomBarColor,
          icons: Icons.carpenter,
          onTap: () {
            _controller.clear();
            howMuchWidget = 0;
          },
          title: 'Eraser',
        ),
      );
    }

    if (widget.isShowingFilter) {
      listMenu.add(
        BottomBarContainer(
          title: 'Filter',
          colors: widget.bottomBarColor,
          icons: Icons.photo,
          onTap: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              context: context,
              builder: (context) {
                return Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setS) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 5),
                          const Text(
                            'Slider Hue',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.grey,
                                  value: hueValue,
                                  min: -10.0,
                                  max: 10.0,
                                  onChanged: (v) {
                                    setS(() {
                                      setState(() {
                                        hueValue = v;
                                      });
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setS(() {
                                    setState(() {
                                      blurValue = 0.0;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Slider Saturation',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Slider(
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.grey,
                                    value: saturationValue,
                                    min: -10.0,
                                    max: 10.0,
                                    onChanged: (v) {
                                      setS(() {
                                        setState(() {
                                          saturationValue = v;
                                        });
                                      });
                                    }),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setS(() {
                                    setState(() {
                                      saturationValue = 0.0;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Slider Brightness',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.grey,
                                  value: brightnessValue,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (v) {
                                    setS(() {
                                      setState(() {
                                        brightnessValue = v;
                                      });
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  setS(() {
                                    setState(() {
                                      brightnessValue = 0.0;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    }

    if (widget.isShowingEmoji) {
      listMenu.add(
        BottomBarContainer(
          title: 'Emoji',
          colors: widget.bottomBarColor,
          icons: Icons.emoji_emotions_outlined,
          onTap: () {
            var getEmojis = showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return const Emojies();
              },
            );
            getEmojis.then((value) {
              if (value['name'] != null) {
                type.add(1);
                widgetJson.add(value);
                offsets.add(Offset.zero);
                howMuchWidget++;
              }
            });
          },
        ),
      );
    }

    if (listMenu.length < 4) {
      return Row(
        children: listMenu.map((element) => Expanded(child: element)).toList(),
      );
    } else {
      // TODO: tampilkan bottom navigation bar untuk jumlah item lebih dari 4
      return const Text('Coming soon');
    }
  }

  Future _uploadFile(String path) async {
    final ref = storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toIso8601String() + p.basename(path));

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();

    widget.onFileChanged(fileUrl);
  }

}

Widget imageFilterLatest({brightness, saturation, hue, child}) {
  return ColorFiltered(
    colorFilter: ColorFilter.matrix(
      ColorFilterGenerator.brightnessAdjustMatrix(
        value: brightness,
      ),
    ),
    child: ColorFiltered(
      colorFilter: ColorFilter.matrix(
        ColorFilterGenerator.saturationAdjustMatrix(
          value: saturation,
        ),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(
          ColorFilterGenerator.hueAdjustMatrix(
            value: hue,
          ),
        ),
        child: child,
      ),
    ),
  );
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Signature(
          controller: _controller,
          height: height.toDouble(),
          width: width.toDouble(),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}
