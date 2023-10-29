// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter/foundation.dart';

/// Extension utility for [Listenable].
extension ListenableSyncExtension<T extends Listenable> on T {
  /// Syncs notifications of this [Listenable] to a [notifier].
  ///
  /// This is a one-way sync. Changes to [notifier] will not be reflected in
  /// this [Listenable].
  ///
  /// Useful for syncing any [Listenable] to a [ChangeNotifier].
  ///
  /// Example:
  /// ```dart
  /// class Counter extends ChangeNotifier {
  ///   late final _count = ValueNotifier(0).sync(this);
  /// }
  /// ```
  T sync(ChangeNotifier notifier) {
    addListener(notifier.notifyListeners);
    return this;
  }
}
