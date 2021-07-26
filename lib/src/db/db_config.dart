/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:localchain/localchain.dart';
import 'package:localchain/src/key_store/key_store_service.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../crypto/crypto.dart' as crypto;

class DbConfig {
  static const int _version = 1;
  static const String _startContents = "START";
  final _log = Logger('DbConfig');
  late Database database;

  Future<void> init(KeyStoreService keyStoreService) async {
    database = await openDatabase(
        join(await getDatabasesPath(), 'blockchain.db'),
        version: _version,
        onConfigure: onConfigure,
        onCreate: (Database db, int version) =>
            onCreate(db, version, keyStoreService),
        onUpgrade: onUpgrade,
        onDowngrade: onDowngrade,
        onOpen: onOpen,
        singleInstance: true);
  }

  Future<void> onConfigure(Database db) async {
    _log.finest('configure');
  }

  Future<void> onCreate(
      Database db, int version, KeyStoreService keyStoreService) async {
    _log.info('create');
    String createSqlScript = await rootBundle
        .loadString('packages/localchain/src/db/db_create_tables.sql');
    List<String> createSqls = createSqlScript.split(";");
    for (String createSql in createSqls) {
      String sql = createSql.trim();
      if (sql.isNotEmpty) await db.execute(sql);
    }
    await _firstBlock(keyStoreService, db);
  }

  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    _log.finest('upgrade');
  }

  Future<void> onDowngrade(Database db, int oldVersion, int newVersion) async {
    _log.finest('downgrade');
  }

  Future<void> onOpen(Database db) async {
    _log.finest('open');
  }

  Future<void> _firstBlock(
      KeyStoreService keyStoreService, Database database) async {
    Uint8List plainTextBytes = Uint8List.fromList(utf8.encode(_startContents));
    Uint8List cipherText =
        crypto.rsaEncrypt(keyStoreService.dataKey!.publicKey, plainTextBytes);
    Uint8List signature =
        crypto.ecdsaSign(keyStoreService.signKey!.privateKey, cipherText);

    await database.insert(
        "block",
        BlockModel(
                contents: cipherText,
                signature: signature,
                previousHash: Uint8List.fromList(List.empty()),
                created: DateTime.now())
            .toMap());
  }
}
