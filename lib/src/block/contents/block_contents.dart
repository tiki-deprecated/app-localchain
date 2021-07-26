/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

abstract class BlockContents {
  String schema;

  BlockContents({required this.schema});

  BlockContents fromBytes(Uint8List bytes);

  Uint8List toBytes();

  String toString();
}
