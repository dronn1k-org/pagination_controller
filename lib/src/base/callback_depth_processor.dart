import 'package:flutter/material.dart';

mixin CallbackDepthProcessor {
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  late final ValueNotifier<int> _processingDepth = ValueNotifier(0)
    ..addListener(_processingDepthListener);

  void _processingDepthListener() {
    isProcessing.value = _processingDepth.value > 0;
  }

  @protected
  T process<T>(T Function() cb) {
    _processingDepth.value += 1;
    try {
      return cb();
    } catch (_) {
      rethrow;
    } finally {
      _processingDepth.value -= 1;
    }
  }

  @protected
  void disposeDepthProcessor() {
    isProcessing.removeListener(_processingDepthListener);
  }
}
