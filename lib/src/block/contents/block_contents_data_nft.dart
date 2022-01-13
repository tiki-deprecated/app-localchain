/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'block_contents.dart';
import 'block_contents_schema.dart';

class BlockContentsDataNft extends BlockContents {
  String? fingerprint;
  String? proof;

  BlockContentsDataNft({this.fingerprint, this.proof})
      : super(BlockContentsSchema.dataNft);

  BlockContentsDataNft.payload(Uint8List bytes)
      : super(BlockContentsSchema.uriNft) {
    int fpLen = bytes.elementAt(0);
    Uint8List fpBytes = bytes.sublist(1, 1 + fpLen);
    int pLen = bytes.elementAt(1 + fpLen);
    Uint8List pBytes = bytes.sublist(2 + fpLen, 2 + fpLen + pLen);
    fingerprint = utf8.decode(fpBytes);
    proof = utf8.decode(pBytes);
  }

  @override
  Uint8List get payload {
    BytesBuilder builder = BytesBuilder();
    Uint8List fpBytes = Uint8List.fromList(utf8.encode(fingerprint!));
    Uint8List pBytes = Uint8List.fromList(utf8.encode(proof!));

    if (fpBytes.length > 255 || pBytes.length > 255)
      throw StateError('byte[] length of proof and fingerprint must be < 255');

    builder.addByte(fpBytes.length);
    builder.add(fpBytes);
    builder.addByte(pBytes.length);
    builder.add(pBytes);
    return builder.toBytes();
  }

  @override
  String toString() {
    return 'BlockContentsDataNft{_schema: $schema, fingerprint: $fingerprint, proof: $proof}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockContentsDataNft &&
          runtimeType == other.runtimeType &&
          fingerprint == other.fingerprint &&
          proof == other.proof;

  @override
  int get hashCode => fingerprint.hashCode ^ proof.hashCode;
}
