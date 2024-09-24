// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:pagination_controller/src/base/pagination_method.dart';

sealed class PaginationControllerState<ItemType, PM extends PaginationMethod,
    ErrorType> {}

class DataListPCState<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationControllerState<ItemType, PM, ErrorType> {
  final List<ItemType> itemList;
  final PM lastPagination;
  final bool isLastItems;

  const DataListPCState({
    required this.itemList,
    required this.lastPagination,
    required this.isLastItems,
  });
}

class EmptyListPCState<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationControllerState<ItemType, PM, ErrorType> {
  final PM lastPagination;

  const EmptyListPCState({
    required this.lastPagination,
  });
}

class ErrorListPCState<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationControllerState<ItemType, PM, ErrorType> {
  final PM lastPagination;
  final ErrorType? description;

  ErrorListPCState({
    required this.lastPagination,
    this.description,
  });
}
