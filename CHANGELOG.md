# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
