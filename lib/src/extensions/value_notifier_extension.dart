import 'package:flutter/foundation.dart';

/// Extension utility for [ValueListenable].
extension AsyncValueNotifierExtension<T> on ValueNotifier<T> {
  /// Sets [value] for [ValueNotifier.value].
  void setValue(T value) {
    this.value = value;
  }
}
