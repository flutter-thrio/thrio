// Copyright (c) 2019/12/03, 11:47:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';

class RegistryMap<K, V> {
  final Map<K, V> _maps = {};

  VoidCallback registry(K key, V value) {
    assert(key != null, 'key must not be null.');
    assert(value != null, 'value must not be null.');

    _maps[key] = value;
    return () {
      _maps.remove(key);
    };
  }

  VoidCallback registryAll(Map<K, V> values) {
    assert(values?.isNotEmpty ?? false, 'values must not be null or empty.');

    _maps.addAll(values);
    return () {
      _maps.removeWhere((k, _) => _maps.containsKey(k));
    };
  }

  Iterable<K> get keys => _maps.keys;

  Iterable<V> get values => _maps.values;

  void clear() => _maps.clear();

  V operator [](K key) => _maps[key];
}
