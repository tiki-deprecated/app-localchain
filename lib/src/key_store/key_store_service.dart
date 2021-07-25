/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/ecc/api.dart';

import '../crypto/crypto.dart' as crypto;
import 'key_store_exception.dart';
import 'key_store_model.dart';
import 'key_store_repository.dart';

class KeyStoreService {
  final KeyStoreRepository _keyStoreRepository;
  KeyStoreModel? _active;
  AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? _signKey;
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? _dataKey;

  KeyStoreService({FlutterSecureStorage? secureStorage})
      : this._keyStoreRepository =
            KeyStoreRepository(secureStorage ?? FlutterSecureStorage());

  Future<void> set(KeyStoreModel model) async {
    await _keyStoreRepository.save(model);
    this._active = model;
  }

  Future<void> load(String address) async {
    KeyStoreModel model = await _keyStoreRepository.get(address);
    if (model.address == null)
      throw KeyStoreException("", address: address);
    else
      this._active = model;
  }

  Future<void> generate() async {
    this._signKey = await crypto.ecdsaGenerate();
    this._dataKey = await crypto.rsaGenerate();
    return set(keysToModel(this._signKey!, this._dataKey!));
  }

  KeyStoreModel keysToModel(
      AsymmetricKeyPair<ECPublicKey, ECPrivateKey> _signKey,
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _dataKey) {
    String ecdsaPublicEncoded = crypto.ecdsaEncodePublicKey(_signKey.publicKey);
    return KeyStoreModel(
        address: crypto.sha3(ecdsaPublicEncoded),
        dataPublicKey: crypto.rsaEncodePublicKey(_dataKey.publicKey),
        dataPrivateKey: crypto.rsaEncodePrivateKey(_dataKey.privateKey),
        signPublicKey: ecdsaPublicEncoded,
        signPrivateKey: crypto.ecdsaEncodePrivateKey(_signKey.privateKey));
  }
}
