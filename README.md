# Local Chain
Dart native implementation of TIKI's single user blockchain. Runs 100% locally, no internet, or external dependencies required. 
- Uses a local SQLite database as the file structure.

## How to Use
- Open the `localchain` with an address 
`Future<Localchain> open(String address, {String? password, Duration? validate})`

*Note: If any of your project's dependencies uses sqflite (e.g: cached_network_image, flutter_cache_manager...), then for iOS to link correctly the SQLCipher libraries you need to override it in your pubspec.yaml file:*

```
dependency_overrides:
  sqflite:
    git:
      url: https://www.github.com/davidmartos96/sqflite_sqlcipher.git
      path: sqflite
      ref: fmdb_override
```

- Append block(s) to the chain using `Future<List<Block>> append(List<Uint8List> contents)`. See `/src/block/contents` for specific block schemas. 

- Validate chain integrity using `Future<bool> validate({int pageSize = 100})`

- Read the chain (in pages) using `Future<List<Block>> get({int pageSize = 100, void Function(List<Block>)? onPage})`

- Use `Localchain.codec` to `encode` and `decode` blocks. 

*Note: block encryption is optional and handled by the wallet implementation. Not the localchain. See [wallet](https://github.com/tiki/wallet) for specifics.*

## How to contribute
Thank you for contributing with the data revolution!    
All the information about contribution can be found in [CONTRIBUTE](https://github.com/tiki/.github/blob/main/profile/CONTRIBUTE.md)

## License
[MIT license](https://github.com/tiki/localchain/blob/main/LICENSE)
