/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'block_contents_schema.dart';

abstract class BlockContents {
  final BlockContentsSchema _schema;

  BlockContents(this._schema);

  BlockContentsSchema get schema => _schema;

  Uint8List get payload;

  @override
  String toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockContents &&
          runtimeType == other.runtimeType &&
          _schema == other._schema;

  @override
  int get hashCode => _schema.hashCode;
}
