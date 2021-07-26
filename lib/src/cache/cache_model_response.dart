/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../block/contents/block_contents.dart';
import '../block/contents/block_contents_codec.dart' as codec;
import 'cache_model.dart';

class CacheModelResponse {
  final CacheModel? model;
  final BlockContents? contents;

  CacheModelResponse.fromModel(CacheModel? model)
      : this.model = model,
        this.contents =
            model?.contents != null ? codec.decode(model!.contents!) : null;

  @override
  String toString() {
    return 'CacheModelResponse{model: $model, contents: $contents}';
  }
}
