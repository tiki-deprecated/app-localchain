/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class DbModelPage<T> {
  int? pageSize;
  int? pageNumber;
  int? totalElements;
  int? totalPages;
  List<T>? elements;

  DbModelPage(
      {this.pageSize,
      this.pageNumber,
      this.totalElements,
      this.totalPages,
      this.elements});

  @override
  String toString() {
    return 'DbModelPage{pageSize: $pageSize, pageNumber: $pageNumber, totalElements: $totalElements, totalPages: $totalPages, elements: [...]}';
  }
}
