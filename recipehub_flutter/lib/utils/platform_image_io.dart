// utils/platform_image_io.dart
// Mobile (non-web) implementation: uses dart:io's File and Image.file
// This file must NOT be imported on web — it's conditionally exported by
// utils/platform_image.dart so that dart:io is never referenced in web builds.

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