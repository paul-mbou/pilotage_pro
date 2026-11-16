import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Target: output size at most 50% of the original bytes (JPEG).
/// Iterates quality and max side until the target is met, then returns that file path.
/// If impossible (e.g. already tiny source), returns the smallest produced file.
Future<String> compressProductImageFromDevice(String sourcePath) async {
  final src = File(sourcePath);
  if (!src.existsSync()) {
    return sourcePath;
  }
  final originalSize = await src.length();
  if (originalSize == 0) {
    return sourcePath;
  }

  final dir = await getTemporaryDirectory();
  const maxSizeFraction = 0.5;
  final targetMaxBytes = (originalSize * maxSizeFraction).floor();

  var quality = 55;
  var minSide = 1600;

  String? bestPath;
  var bestSize = originalSize;

  Future<void> deleteIfNotSource(String path) async {
    if (path == sourcePath) return;
    try {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
  }

  for (var attempt = 0; attempt < 14 && quality >= 18; attempt++) {
    final outPath =
        '${dir.path}/pp_${DateTime.now().microsecondsSinceEpoch}_$attempt.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      outPath,
      quality: quality,
      minWidth: minSide,
      minHeight: minSide,
      keepExif: false,
    );
    if (result == null) {
      quality -= 8;
      minSide = (minSide * 0.9).round().clamp(640, 2048);
      continue;
    }

    final newSize = await File(result.path).length();

    if (newSize <= targetMaxBytes) {
      if (bestPath != null) {
        await deleteIfNotSource(bestPath);
      }
      return result.path;
    }

    if (newSize < bestSize) {
      if (bestPath != null) {
        await deleteIfNotSource(bestPath);
      }
      bestPath = result.path;
      bestSize = newSize;
    } else {
      await deleteIfNotSource(result.path);
    }

    quality -= 5;
    minSide = (minSide * 0.92).round().clamp(640, 2048);
  }

  if (bestPath != null) {
    return bestPath;
  }

  return sourcePath;
}
