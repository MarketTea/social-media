import 'package:flutter/material.dart';

class EmojiView extends StatefulWidget {
  final double left;
  final double top;
  final Function onTap;
  final Map mapJson;
  final Function(DragUpdateDetails) onUpdate;

  const EmojiView({
    Key key,
    this.left,
    this.top,
    this.onTap,
    this.onUpdate,
    this.mapJson,
  }) : super(key: key);

  @override
  _EmojiViewState createState() => _EmojiViewState();
}

class _EmojiViewState extends State<EmojiView> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
        onTap: widget.onTap as void Function(),
        onPanUpdate: widget.onUpdate,
        child: Text(
          widget.mapJson['name'].toString(),
          textAlign: widget.mapJson['align'],
          style: TextStyle(
            color: widget.mapJson['color'],
            fontSize: widget.mapJson['size'],
          ),
        ),
      ),
    );
  }
}
