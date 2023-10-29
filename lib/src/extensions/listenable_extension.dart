// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';

/// Extension utility for [Listenable].
extension AsyncListenableExtension<T extends Listenable> on T {
  /// Syncs a [ChangeNotifier] with this [Listenable].
  T sync(ChangeNotifier notifier) {
    addListener(notifier.notifyListeners);
    return this;
  }
}
