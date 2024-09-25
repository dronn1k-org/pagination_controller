/// Abstract class that defines the pagination method interface.
///
/// This class provides an interface for implementing different pagination
/// strategies such as offset-based or page-based pagination.
abstract class PaginationMethod {
  /// Returns the first page of pagination, optionally with a [limit] on items per page.
  PaginationMethod first([int? limit]);

  /// Returns the next page of pagination, optionally with a [limit] on items per page.
  PaginationMethod next([int? limit]);

  /// Retrieves all current pages.
  PaginationMethod allCurrent();

  /// Checks if the last element of the list has been reached, given the [elementCount].
  bool isLastElementList(int elementCount);
}

class OffsetPagination implements PaginationMethod {
  final int limit;

  final int offset;

  const OffsetPagination({
    required this.offset,
    this.limit = 10,
  })  : assert(offset >= 0, 'Offset number should be higher or equal than 0'),
        assert(limit > 0, 'Limit number should be higher than 0');

  @override
  PaginationMethod first([int? limit]) {
    limit ??= this.limit;
    return OffsetPagination(offset: offset);
  }

  @override
  PaginationMethod next([int? limit]) => OffsetPagination(
      offset: offset + (limit ?? this.limit), limit: limit ?? this.limit);

  @override
  PaginationMethod allCurrent() =>
      OffsetPagination(offset: 0, limit: offset + limit);

  @override
  bool isLastElementList(int elementCount) => elementCount != limit;
}

class PagePagination implements PaginationMethod {
  final int page;
  final int limit;

  const PagePagination({
    required this.page,
    this.limit = 10,
  })  : assert(page > 0, 'Page number should be higher than 0'),
        assert(limit > 0, 'Limit number should be higher than 0');

  @override
  PaginationMethod allCurrent() => PagePagination(page: 1, limit: page * limit);

  @override
  PaginationMethod first([int? limit]) =>
      PagePagination(page: 1, limit: limit ?? this.limit);

  @override
  PaginationMethod next([int? limit]) {
    return PagePagination(page: page + 1, limit: limit ?? this.limit);
  }

  @override
  bool isLastElementList(int elementCount) => elementCount != limit;
}
