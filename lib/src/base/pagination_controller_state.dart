import 'package:pagination_controller/src/base/pagination_method.dart';

/// Base class that defines the state of the pagination controller.
///
/// [ItemType] is the type of items being paginated.
/// [PM] is the pagination method used.
/// [ErrorType] represents possible errors.
sealed class PaginationControllerState<ItemType, PM extends PaginationMethod,
    ErrorType> {
  /// Creates a new state with the updated pagination pointer.
  PaginationControllerState<ItemType, PM, ErrorType> copyWithPagination(
      PM pagination);
}

/// Represents a state with data in the list.
///
/// Contains [itemList] and the [lastPagination] pointer.
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

  @override
  DataListPCState<ItemType, PM, ErrorType> copyWithPagination(PM pagination) {
    return DataListPCState(
        itemList: itemList,
        lastPagination: pagination,
        isLastItems: isLastItems);
  }
}

/// Represents an empty list state.
///
/// Contains only the [lastPagination] pointer.
class EmptyListPCState<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationControllerState<ItemType, PM, ErrorType> {
  final PM lastPagination;

  const EmptyListPCState({
    required this.lastPagination,
  });

  @override
  EmptyListPCState<ItemType, PM, ErrorType> copyWithPagination(PM pagination) {
    return EmptyListPCState(
      lastPagination: pagination,
    );
  }
}

/// Represents an error state with an optional [description].
class ErrorListPCState<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationControllerState<ItemType, PM, ErrorType> {
  final PM lastPagination;
  final ErrorType? description;

  ErrorListPCState({
    required this.lastPagination,
    this.description,
  });

  @override
  ErrorListPCState<ItemType, PM, ErrorType> copyWithPagination(PM pagination) {
    return ErrorListPCState(
      description: description,
      lastPagination: pagination,
    );
  }
}
