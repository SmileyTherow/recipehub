// utils/platform_image_web.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget buildImageFromXFile(
  XFile xfile, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  return FutureBuilder<Uint8List>(
    future: xfile.readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      if (snapshot.hasError || snapshot.data == null) {
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Colors.grey,
            ),
          ),
        );
      }
      return Image.memory(
        snapshot.data!,
        fit: fit,
        width: width,
        height: height,
      );
    },
  );
}