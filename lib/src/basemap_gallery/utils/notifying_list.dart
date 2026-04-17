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
final class _NotifyingList<E> extends ChangeNotifier with ListMixin<E> {
  final List<E> _inner = <E>[];

  bool _disposed = false;

  int _mutationDepth = 0;
  bool _notifyPending = false;

  T _batch<T>(T Function() fn) {
    if (_disposed) {
      return fn();
    }

    _mutationDepth++;
    try {
      return fn();
    } finally {
      _mutationDepth--;

      if (_mutationDepth == 0 && _notifyPending && !_disposed) {
        _notifyPending = false;
        notifyListeners();
      }
    }
  }

  void _changed() {
    if (_disposed) return;
    if (_mutationDepth > 0) {
      _notifyPending = true;
      return;
    }

    notifyListeners();
  }

  void _mutate(void Function() fn) {
    _batch<void>(() {
      fn();
      _notifyPending = true;
    });
  }

  T _mutateReturn<T>(T Function() fn) {
    return _batch<T>(() {
      final result = fn();
      _notifyPending = true;
      return result;
    });
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
  void addAll(Iterable<E> iterable) {
    final previousLength = _inner.length;
    _inner.addAll(iterable);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    final items = iterable is List<E> ? iterable : iterable.toList();
    if (items.isEmpty) {
      // Preserve range-check semantics but avoid notifying.
      _inner.insertAll(index, items);
      return;
    }
    _mutate(() => _inner.insertAll(index, items));
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    final items = iterable is List<E> ? iterable : iterable.toList();
    if (items.isEmpty) {
      _inner.setAll(index, items);
      return;
    }
    _mutate(() => _inner.setAll(index, items));
  }

  @override
  void setRange(
    int start,
    int end,
    Iterable<E> iterable, [
    int skipCount = 0,
  ]) {
    if (start == end) {
      _inner.setRange(start, end, iterable, skipCount);
      return;
    }
    _mutate(() => _inner.setRange(start, end, iterable, skipCount));
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacements) {
    final items = replacements is List<E> ? replacements : replacements.toList();
    if (start == end && items.isEmpty) {
      _inner.replaceRange(start, end, items);
      return;
    }
    _mutate(() => _inner.replaceRange(start, end, items));
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    if (start == end) {
      _inner.fillRange(start, end, fillValue);
      return;
    }
    _mutate(() => _inner.fillRange(start, end, fillValue));
  }

  @override
  void removeRange(int start, int end) {
    if (start == end) {
      _inner.removeRange(start, end);
      return;
    }
    _mutate(() => _inner.removeRange(start, end));
  }

  @override
  void removeWhere(bool Function(E element) test) {
    final previousLength = _inner.length;
    _inner.removeWhere(test);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void retainWhere(bool Function(E element) test) {
    final previousLength = _inner.length;
    _inner.retainWhere(test);
    if (_inner.length != previousLength) {
      _changed();
    }
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _mutate(() => _inner.sort(compare));
  }

  @override
  void shuffle([math.Random? random]) {
    _mutate(() => _inner.shuffle(random));
  }

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
