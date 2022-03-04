import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppRoundImage extends StatelessWidget {
  final ImageProvider provider;
  final double height;
  final double width;

  const AppRoundImage(
    this.provider, {
    Key key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Image(
        image: provider,
        height: height,
        width: width,
      ),
    );
  }

  factory AppRoundImage.url(
    String url, {
    double height,
    double width,
  }) {
    return AppRoundImage(
      NetworkImage(url),
      height: height,
      width: width,
    );
  }

  factory AppRoundImage.memory(
    Uint8List data, {
    double height,
    double width,
  }) {
    return AppRoundImage(
      MemoryImage(data),
      height: height,
      width: width,
    );
  }
}
