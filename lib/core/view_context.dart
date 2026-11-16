import 'package:flutter/material.dart';

/// [View] helpers to avoid [MediaQuery.sizeOf] in layout (e.g. [AlertDialog]).
extension BuildContextViewX on BuildContext {
  /// [View] width in physical pixels: [View] of (this) .physicalSize.width
  double get viewPhysicalWidth => View.of(this).physicalSize.width;

  /// [View] width in logical pixels (same scale as [MediaQuery.sizeOf] width).
  double get viewWidth => viewPhysicalWidth / View.of(this).devicePixelRatio;

  /// [View] height in physical pixels: [View] of (this) .physicalSize.height
  double get viewPhysicalHeight => View.of(this).physicalSize.height;

  /// [View] height in logical pixels (same scale as [MediaQuery.sizeOf] height).
  double get viewHeight => viewPhysicalHeight / View.of(this).devicePixelRatio;
}
