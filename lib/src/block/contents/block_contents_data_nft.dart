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
      : super(BlockContentsSchema.dataNft) {
    try {
      int fpLen = bytes.elementAt(0);
      Uint8List fpBytes = bytes.sublist(1, 1 + fpLen);
      int pLen = bytes.elementAt(1 + fpLen);
      Uint8List pBytes = bytes.sublist(2 + fpLen, 2 + fpLen + pLen);
      fingerprint = utf8.decode(fpBytes);
      proof = utf8.decode(pBytes);
    } catch (error) {
      throw FormatException('failed to decode block', bytes);
    }
  }

  @override
  Uint8List get payload {
    BytesBuilder builder = BytesBuilder();
    if (fingerprint == null) throw FormatException('fingerprint required');
    if (proof == null) throw FormatException('proof required');

    Uint8List fpBytes = Uint8List.fromList(utf8.encode(fingerprint!));
    Uint8List pBytes = Uint8List.fromList(utf8.encode(proof!));

    if (fpBytes.length > 255)
      throw FormatException(
          'fingerprint byte[] length must be < 255', fingerprint);

    if (pBytes.length > 255)
      throw FormatException('proof byte[] length must be < 255', proof);

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
      super == other &&
          other is BlockContentsDataNft &&
          runtimeType == other.runtimeType &&
          fingerprint == other.fingerprint &&
          proof == other.proof;

  @override
  int get hashCode => super.hashCode ^ fingerprint.hashCode ^ proof.hashCode;
}
