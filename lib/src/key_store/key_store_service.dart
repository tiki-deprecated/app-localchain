/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/digests/sha3.dart';
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

  KeyStoreModel? get active => this._active;
  AsymmetricKeyPair<ECPublicKey, ECPrivateKey>? get signKey => this._signKey;
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? get dataKey => this._dataKey;

  Future<void> set(KeyStoreModel model) async {
    if (model.address == null ||
        model.dataPrivateKey == null ||
        model.signPrivateKey == null)
      throw KeyStoreException("Missing required parameter(s)",
          address: model.address);

    _decodeModel(model);

    if (model.dataPublicKey == null)
      model.dataPublicKey = crypto.rsaEncodePublicKey(this._dataKey!.publicKey);
    if (model.signPublicKey == null)
      model.signPublicKey =
          crypto.ecdsaEncodePublicKey(this._signKey!.publicKey);

    if (!_checkDataKey())
      throw KeyStoreException("Invalid Key Pair - Data",
          address: model.address);
    if (!_checkSignKey())
      throw KeyStoreException("Invalid Key Pair - Sign",
          address: model.address);

    await _keyStoreRepository.save(model);
    this._active = model;
  }

  Future<void> load(String address) async {
    KeyStoreModel model = await _keyStoreRepository.get(address);
    if (model.address == null)
      throw KeyStoreException("Address not found", address: address);
    else {
      _decodeModel(model);
      this._active = model;
    }
  }

  Future<void> generate() async {
    this._signKey = await crypto.ecdsaGenerate();
    this._dataKey = await crypto.rsaGenerate();

    KeyStoreModel model = KeyStoreModel(
        address: _deriveAddress(_signKey!.publicKey),
        dataPublicKey: crypto.rsaEncodePublicKey(_dataKey!.publicKey),
        dataPrivateKey: crypto.rsaEncodePrivateKey(_dataKey!.privateKey),
        signPublicKey: crypto.ecdsaEncodePublicKey(_signKey!.publicKey),
        signPrivateKey: crypto.ecdsaEncodePrivateKey(_signKey!.privateKey));

    await _keyStoreRepository.save(model);
    this._active = model;
  }

  void _decodeModel(KeyStoreModel model) {
    ECPrivateKey ecPrivateKey =
        crypto.ecdsaDecodePrivateKey(model.signPrivateKey!);
    ECPublicKey ecPublicKey = model.signPublicKey != null
        ? crypto.ecdsaDecodePublicKey(model.signPublicKey!)
        : crypto.ecdsaPublicKey(ecPrivateKey);

    RSAPrivateKey rsaPrivateKey =
        crypto.rsaDecodePrivateKey(model.dataPrivateKey!);
    RSAPublicKey rsaPublicKey = model.dataPublicKey != null
        ? crypto.rsaDecodePublicKey(model.dataPublicKey!)
        : crypto.rsaPublicKey(rsaPrivateKey);

    this._signKey =
        AsymmetricKeyPair<ECPublicKey, ECPrivateKey>(ecPublicKey, ecPrivateKey);
    this._dataKey = AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
        rsaPublicKey, rsaPrivateKey);
  }

  String _deriveAddress(ECPublicKey publicKey) {
    final SHA3Digest sha3256 = SHA3Digest(256);
    String encodedKey = crypto.ecdsaEncodePublicKey(publicKey);
    Uint8List hash = sha3256.process(utf8.encode(encodedKey) as Uint8List);
    return hash.map((b) => '${b.toRadixString(16).padLeft(2, '0')}').join("");
  }

  bool _checkSignKey() {
    if (_signKey == null) return false;
    Uint8List message = Uint8List.fromList(utf8.encode("Check"));
    Uint8List signature = crypto.ecdsaSign(_signKey!.privateKey, message);
    return crypto.ecdsaVerify(_signKey!.publicKey, signature, message);
  }

  bool _checkDataKey() {
    if (_dataKey == null) return false;
    Uint8List input = Uint8List.fromList(utf8.encode("Check"));
    Uint8List cipher = crypto.rsaEncrypt(_dataKey!.publicKey, input);
    Uint8List output = crypto.rsaDecrypt(_dataKey!.privateKey, cipher);
    return (utf8.decode(input) == utf8.decode(output));
  }
}
