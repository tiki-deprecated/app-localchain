library localchain;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localchain/src/block/block_service.dart';

import 'src/block/block_model.dart';
import 'src/db/db_config.dart';
import 'src/key_store/key_store_service.dart';

export 'src/block/block_model.dart';
export 'src/key_store/key_store_model.dart';

class Localchain {
  final DbConfig _dbConfig = DbConfig();
  late final BlockService _blockService;

  final KeyStoreService keystore;

  Localchain({FlutterSecureStorage? secureStorage})
      : this.keystore = KeyStoreService(secureStorage: secureStorage);

  Future<void> init() async {
    await _dbConfig.init();
    this._blockService = BlockService(_dbConfig);
  }

  Future<BlockModel> add(String plaintext) => _blockService.add(plaintext);
}
