import 'package:flutter/material.dart';

class TextView extends StatefulWidget {
  final double left;
  final double top;
  final Function onTap;
  final Function(DragUpdateDetails) onUpdate;
  final Map mapJson;

  const TextView({
    Key key,
    this.left,
    this.top,
    this.onTap,
    this.onUpdate,
    this.mapJson,
  }) : super(key: key);

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
        onTap: widget.onTap as void Function(),
        onPanUpdate: widget.onUpdate,
        child: Text(
          widget.mapJson['name'],
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
