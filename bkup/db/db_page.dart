/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class DbPage<T> {
  int? pageSize;
  int? pageNumber;
  int? totalElements;
  int? totalPages;
  List<T> elements;

  DbPage(
      {this.pageSize,
      this.pageNumber,
      this.totalElements,
      this.totalPages,
      List<T>? elements})
      : this.elements = elements ?? List.empty(growable: true);

  @override
  String toString() {
    return 'DbPage{pageSize: $pageSize, pageNumber: $pageNumber, totalElements: $totalElements, totalPages: $totalPages}';
  }
}
