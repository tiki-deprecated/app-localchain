/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../block/block_model.dart';

class CacheModel {
  Uint8List? contents;
  DateTime? cached;
  BlockModel? block;

  CacheModel({this.contents, this.cached, this.block});

  CacheModel.fromMap(Map<String, dynamic> map) {
    this.contents = map['contents'];
    if (map['cached_epoch'] != null)
      this.cached = DateTime.fromMillisecondsSinceEpoch(map['cached_epoch']);
    this.block = BlockModel.fromMap(map['block']);
  }

  Map<String, dynamic> toMap() => {
        'contents': contents,
        'cached_epoch': cached?.millisecondsSinceEpoch,
        'block_id': block?.id
      };

  @override
  String toString() {
    return 'CacheModel{contents: $contents, cached: $cached, block: $block}';
  }
}
