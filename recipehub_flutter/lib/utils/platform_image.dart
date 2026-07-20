// utils/platform_image.dart
//
// Conditional export that re-exports the platform-specific implementation
// of `buildImageFromXFile`. For non-web platforms it exports
// platform_image_io.dart (which uses dart:io and Image.file).
// For web it exports platform_image_web.dart (which uses Image.memory).
//
// This file MUST NOT import flutter or dart:io; it only re-exports the
// platform-specific implementation so that dart:io is never referenced
// in web builds.
//
// Usage:
//   import 'package:your_package/utils/platform_image.dart';
//   ...
//   Widget imageWidget = buildImageFromXFile(xfile, fit: BoxFit.cover);

export 'platform_image_io.dart'
  if (dart.library.html) 'platform_image_web.dart';