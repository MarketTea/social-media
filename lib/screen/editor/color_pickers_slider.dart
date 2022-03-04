import 'package:flutter/material.dart';

import 'colors_picker.dart';

class ColorPickersSlider extends StatefulWidget {
  @override
  _ColorPickersSliderState createState() => _ColorPickersSliderState();
}

class _ColorPickersSliderState extends State<ColorPickersSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(20),
      height: 240,
      child: Column(
        children: [
          Center(
            child: Text(
              'Slider Filter Color'.toUpperCase(),
            ),
          ),
          const Divider(),
          const SizedBox(height: 20.0),
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
          const SizedBox(height: 5.0),
          const Text('Slider Opacity'),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Slider(
                  value: 0.1,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (v) {},
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
    );
  }
}
