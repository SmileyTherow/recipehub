// utils/platform_image_io.dart
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

Widget buildImageFromXFile(
  XFile xfile, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  return Image.file(
    File(xfile.path),
    fit: fit,
    width: width,
    height: height,
  );
}