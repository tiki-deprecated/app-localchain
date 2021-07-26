/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

class BlockModel {
  int? id;
  Uint8List? contents;
  Uint8List? signature;
  Uint8List? previousHash;
  DateTime? created;

  BlockModel(
      {this.id,
      this.contents,
      this.signature,
      this.previousHash,
      this.created});

  BlockModel.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.contents = map['contents'];
    this.signature = map['signature'];
    this.previousHash = map['previous_hash'];
    if (map['created_epoch'] != null)
      this.created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'contents': contents,
        'signature': signature,
        'previous_hash': previousHash,
        'created_epoch': created?.millisecondsSinceEpoch
      };

  @override
  String toString() {
    return 'BlockModel{id: $id, created: $created}';
  }
}
