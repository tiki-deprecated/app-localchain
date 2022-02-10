/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:collection/collection.dart';

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
      super == other &&
          other is BlockContentsBytea &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(body, other.body);

  @override
  int get hashCode => super.hashCode ^ body.hashCode;
}
