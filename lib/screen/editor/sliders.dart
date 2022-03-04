import 'package:flutter/material.dart';
import 'package:kadai_app/widgets/image_editor_pro.dart';

import 'colors_picker.dart';

class Sliders extends StatefulWidget {
  final int index;
  final Map mapValue;

  const Sliders({Key key, this.mapValue, this.index}) : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    //  slider = widget.sizevalue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Size Adjust'.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const Divider(),
          Slider(
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            value: widgetJson[widget.index]['size'],
            min: 0.0,
            max: 100.0,
            onChangeEnd: (v) {
              setState(() {
                widgetJson[widget.index]['size'] = v.toDouble();
              });
            },
            onChanged: (v) {
              setState(() {
                slider = v;
                widgetJson[widget.index]['size'] = v.toDouble();
              });
            },
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('Slider Color'),
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
                          setState(() {
                            widgetJson[widget.index]['color'] = Color(value);
                          });
                        },
                      ),
                    ),
                    TextButton(
                      child: const Text('Reset'),
                      onPressed: () {},
                    ),
                  ],
                ),
                const Text('Slider White Black Color'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: BarColorPicker(
                        width: 300,
                        thumbColor: Colors.white,
                        cornerRadius: 10,
                        pickMode: PickMode.Grey,
                        colorListener: (int value) {
                          setState(() {
                            widgetJson[widget.index]['color'] = Color(value);
                          });
                        },
                      ),
                    ),
                    TextButton(
                      child: const Text('Reset'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                  child: const Text('Remove'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    widgetJson.removeAt(widget.index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
