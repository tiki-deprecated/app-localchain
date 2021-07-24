/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class BlockModel {
  int? id;
  String? contents;
  String? previousHash;
  DateTime? created;

  BlockModel({this.id, this.contents, this.previousHash, this.created});

  BlockModel.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.contents = map['contents'];
    this.previousHash = map['previous_hash'];
    if (map['created_epoch'] != null)
      this.created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
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
}
