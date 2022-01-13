/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsJson extends BlockContents {
  String? json;

  BlockContentsJson({this.json}) : super(BlockContentsSchema.json);

  BlockContentsJson.payload(Uint8List bytes)
      : json = utf8.decode(bytes),
        super(BlockContentsSchema.json);

  @override
  Uint8List get payload => Uint8List.fromList(utf8.encode(json!));

  @override
  String toString() {
    return 'BlockContentsJson{_schema: $schema, json: $json}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockContentsJson &&
          runtimeType == other.runtimeType &&
          json == other.json;

  @override
  int get hashCode => json.hashCode;
}
