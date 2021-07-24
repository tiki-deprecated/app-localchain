/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'key_store_model.dart';

class KeyStoreRepository {
  static const _keyPrefix = 'com.mytiki.localchain.keystore.';
  final FlutterSecureStorage secureStorage;

  KeyStoreRepository(this.secureStorage);

  Future<void> save(KeyStoreModel model) async {
    await secureStorage.write(
        key: _keyPrefix + model.address!, value: jsonEncode(model.toJson()));
  }

  Future<KeyStoreModel> get(String address) async {
    String? raw = await secureStorage.read(key: _keyPrefix + address);
    Map<String, dynamic>? jsonMap;
    if (raw != null) jsonMap = jsonDecode(raw);
    return KeyStoreModel.fromJson(jsonMap);
  }
}
