# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.6.0 - Oct 19, 2025

- Changes `AsyncListenable` to a mixin that implements `AsyncSnapshot`.
- Changes `AsyncNotifier` to extend with `AsyncListenable`.
- Added `AsyncSnapshot.errorMessage`.
- Removes `AsyncListenable.snapshot`. Use itself instead.

## 0.5.0 - Dec 14, 2024

- Simplifies `AsyncNotifier`.
- Removes `AsyncNotifier.onData`.
- Removes `AsyncNotifier.onError`.
- Removes `DataChanged` typedef.
- Removes `ErrorCallback` typedef.
- Added `AsyncSnapshotExtension.whenData`.
- Added `AsyncSnapshotExtension.whenError`.
- Updated `AsyncValueListenableExtension.asAsync`.
- Updated `README.md`.
- Updated docs.

## 0.4.0 - Dec 02, 2024

- Simplifies `AsyncNotifier`.
- Removes `AsyncNotifier.late`.
- Removes `AsyncNotifier` setters.
- Removes `AsyncListenable` getters.
- Removes `AsyncListenable` extensions.

## 0.3.2 - Feb 06, 2024

- Adds `requireValue` extension to `AsyncNotifier`. Deprecates `requireData`.
- Adds `maybeWhen` extension to `AsyncNotifier`.
- Changes nullable `StackTrace?` in `AsyncSnapshot` to be non-nullable.
- Changes `AsyncNotifier.when` for `Future<T?>`. Now completes with `null` instead of requiring it.
- Changes `isReloading`. Now considers `hasError` in all cases, instead of just `hasData`.
- Updated tests.

## 0.2.3 - Oct 31, 2023

- BREAKING CHANGE: Removed `reloading` parameter from `when` extension. Use `isReloading` inside `data` parameter instead.
- Adds `skipLoading` in `when` extension.
- Adds `whenOrNull` extension to `AsyncSnapshot` extension and `AsyncNotifier`.
- Adds `hasNone` extension to `AsyncSnapshot` and `AsyncNotifier`.
- Adds `setValue` in `AsyncNotifier` with `notify = true` optional parameter.
- Adds `setValue` as an extension to `ValueNotifier`.
- Adds `listen` method as an extension to `ValueListenable`.
- Adds `sync` method as an extension to `Listenable`.
- Updated documentation of extensions.
- Updated example.
- Updated tests.

## 0.1.1 - Oct 18, 2023

- Adds `cancel()` method to `AsyncNotifier`:
Now you can manually unsubscribe to current future! (and stream). This will
essentially cancel stream or ignore future result. Setting them to null and
`ConnectionState` to none.

- Fixes a problem where the stream wasn't being cast as broadcast correctly.
- Updates `future` and `stream` setters to better address initial values.
- Updates README.md
- Removes unnecessary asserts on `AsyncSnapshot` xtension.

## 0.1.0 - Oct 15, 2023

- Initial pre-release.
