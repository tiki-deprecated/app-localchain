/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsBytea extends BlockContents {
  Uint8List? body;

  BlockContentsBytea({this.body}) : super(BlockContentsSchema.bytea);

  BlockContentsBytea.payload(Uint8List bytes)
      : body = bytes,
        super(BlockContentsSchema.bytea);

  @override
  Uint8List get payload => body ?? Uint8List(0);

  @override
  String toString() {
    return 'BlockContentsBytea{_schema: $schema, body: $body}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockContentsBytea &&
          runtimeType == other.runtimeType &&
          body.toString() == other.body.toString();

  @override
  int get hashCode => body.hashCode;
}
