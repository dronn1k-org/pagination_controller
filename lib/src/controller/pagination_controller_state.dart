// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:pagination_controller/src/controller/pagination_method.dart';

sealed class PaginationControllerState<ItemType, PM extends PaginationMethod> {}

class DataListPCState<ItemType, PM extends PaginationMethod>
    implements PaginationControllerState<ItemType, PM> {
  final List<ItemType> itemList;
  final PM lastPagination;
  final bool isLastItems;

  const DataListPCState({
    required this.itemList,
    required this.lastPagination,
    required this.isLastItems,
  });
}

class EmptyListPCState<ItemType, PM extends PaginationMethod>
    implements PaginationControllerState<ItemType, PM> {}

class ErrorListPCState<ItemType, PM extends PaginationMethod>
    implements PaginationControllerState<ItemType, PM> {}
