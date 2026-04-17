//
// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

part of '../../../arcgis_maps_toolkit.dart';

/// A regular, growable `List` that notifies listeners when it changes.
///
/// This exists so [BasemapGalleryController.gallery] can match the design
/// requirement:
/// - You can call `controller.gallery.add(...)` / `remove(...)` directly.
/// - The [BasemapGallery] UI still updates, because this list is a
///   [Listenable].
///
/// If several mutations happen in quick succession, notifications are queued
/// to a microtask so they are usually delivered once per event-loop tick
/// instead of once per operation.
final class _NotifyingList<E> extends ChangeNotifier with ListMixin<E> {
  final List<E> _inner = <E>[];

  bool _notifyScheduled = false;
  bool _disposed = false;

  void _changed() {
    if (_disposed) return;
    if (_notifyScheduled) return;

    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      if (_disposed) return;
      notifyListeners();
    });
  }

  void _mutate(void Function() fn) {
    fn();
    _changed();
  }

  T _mutateReturn<T>(T Function() fn) {
    final result = fn();
    _changed();
    return result;
  }

  /// Replaces all items, notifying listeners once.
  void replaceAll(Iterable<E> items) {
    _mutate(() {
      _inner
        ..clear()
        ..addAll(items);
    });
  }

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) {
    if (_inner.length == newLength) return;
    _inner.length = newLength;
    _changed();
  }

  @override
  E operator [](int index) => _inner[index];

  @override
  void operator []=(int index, E value) {
    _inner[index] = value;
    _changed();
  }

  @override
  void add(E value) => _mutate(() => _inner.add(value));

  @override
  void addAll(Iterable<E> iterable) => _mutate(() => _inner.addAll(iterable));

  @override
  void clear() {
    if (_inner.isEmpty) return;
    _inner.clear();
    _changed();
  }

  @override
  bool remove(Object? value) {
    final removed = _inner.remove(value);
    if (removed) {
      _changed();
    }
    return removed;
  }

  @override
  E removeAt(int index) => _mutateReturn(() => _inner.removeAt(index));

  @override
  void insert(int index, E element) =>
      _mutate(() => _inner.insert(index, element));

  @override
  E removeLast() => _mutateReturn(_inner.removeLast);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
