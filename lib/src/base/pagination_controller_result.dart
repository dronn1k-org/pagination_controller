import 'package:pagination_controller/src/base/pagination_method.dart';

/// Base class for pagination result.
///
/// [ItemType] represents the type of items returned by pagination.
/// [PM] is the pagination method used.
/// [ErrorType] represents possible errors.
sealed class PaginationResult<ItemType, PM extends PaginationMethod,
    ErrorType> {}

/// Represents a successful pagination result.
///
/// Contains a list of [itemList] and the [pagination] pointer.
class SuccessPaginationResult<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationResult<ItemType, PM, ErrorType> {
  final List<ItemType> itemList;
  final PM pagination;

  const SuccessPaginationResult({
    required this.itemList,
    required this.pagination,
  });

  /// Indicates if the last page of items has been fetched.
  bool get isLastItemList => pagination.isLastElementList(itemList.length);
}

/// Represents a failed pagination result.
///
/// Contains the [pagination] pointer and optional [data] representing the error.
class ErrorPaginationResult<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationResult<ItemType, PM, ErrorType> {
  final PM pagination;
  final ErrorType? data;

  const ErrorPaginationResult({
    required this.pagination,
    this.data,
  });
}
