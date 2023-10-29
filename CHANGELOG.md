# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.2.0 - Oct 29, 2023

- BREAKING CHANGE: Removed `reloading` parameter from `when` extension. Use `isReloading` inside `data` parameter instead.
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
