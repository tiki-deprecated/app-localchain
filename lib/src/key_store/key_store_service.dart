/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../crypto/crypto.dart' as crypto;
import 'key_store_exception.dart';
import 'key_store_model.dart';
import 'key_store_repository.dart';

class KeyStoreService {
  final KeyStoreRepository _keyStoreRepository;
  KeyStoreModel? active;

  KeyStoreService({FlutterSecureStorage? secureStorage})
      : this._keyStoreRepository =
            KeyStoreRepository(secureStorage ?? FlutterSecureStorage());

  Future<void> set(KeyStoreModel model) async {
    await _keyStoreRepository.save(model);
    this.active = model;
  }

  Future<void> load(String address) async {
    KeyStoreModel model = await _keyStoreRepository.get(address);
    if (model.address == null)
      throw KeyStoreException("", address: address);
    else
      this.active = model;
  }

  Future<void> generate() async {
    crypto.CryptoKeyPair ecdsaKeyPair = await crypto.ecdsaGenerate();
    crypto.CryptoKeyPair rsaKeyPair = await crypto.rsaGenerate();
    return set(KeyStoreModel(
      address: crypto.sha3(ecdsaKeyPair.public),
      dataPrivateKey: rsaKeyPair.private,
      dataPublicKey: rsaKeyPair.public,
      signPrivateKey: ecdsaKeyPair.private,
      signPublicKey: ecdsaKeyPair.public,
    ));
  }
}
