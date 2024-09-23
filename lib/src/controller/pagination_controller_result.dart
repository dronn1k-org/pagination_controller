import 'package:pagination_controller/src/controller/pagination_method.dart';

sealed class PaginationResult<ItemType, PM extends PaginationMethod,
    ErrorType> {}

class SuccessPaginationResult<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationResult<ItemType, PM, ErrorType> {
  final List<ItemType> itemList;
  final PM pagination;

  const SuccessPaginationResult({
    required this.itemList,
    required this.pagination,
  });

  bool get isLastItemList => pagination.isLastElementList(itemList.length);
}

class ErrorPaginationResult<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationResult<ItemType, PM, ErrorType> {
  final ErrorType? data;

  const ErrorPaginationResult([this.data]);
}
