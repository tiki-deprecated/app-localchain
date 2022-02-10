/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class BlockModel {
  int? id;
  Uint8List? contents;
  Uint8List? previousHash;
  DateTime? created;

  BlockModel({this.id, this.contents, this.previousHash, this.created});

  BlockModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.id = map['id'];
      this.contents = map['contents'];
      this.previousHash = map['previous_hash'];
      if (map['created_epoch'] != null)
        this.created =
            DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'contents': contents,
        'previous_hash': previousHash,
        'created_epoch': created?.millisecondsSinceEpoch
      };

  @override
  String toString() {
    return 'BlockModel{id: $id, contents: $contents, previousHash: $previousHash, created: $created}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(contents, other.contents) &&
          listEquals(previousHash, other.previousHash) &&
          created == other.created;

  @override
  int get hashCode =>
      id.hashCode ^
      contents.hashCode ^
      previousHash.hashCode ^
      created.hashCode;
}
