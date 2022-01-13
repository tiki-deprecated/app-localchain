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
  bool operator ==(Object other);

  @override
  int get hashCode;
}
