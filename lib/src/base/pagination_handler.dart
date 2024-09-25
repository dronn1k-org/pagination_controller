import 'package:flutter/foundation.dart';
import 'package:pagination_controller/src/base/pagination_controller.dart';
import 'package:pagination_controller/src/base/pagination_controller_result.dart';
import 'package:pagination_controller/src/base/pagination_controller_state.dart';
import 'package:pagination_controller/src/base/pagination_method.dart';

/// Mixin that provides pagination handling logic.
///
/// This mixin implements the methods of [PaginationController] and provides
/// the core logic for handling the pagination process, including fetching
/// the first page, the next page, and refreshing the current pagination.
///
/// [ItemType] is the type of items being paginated.
/// [PM] is the pagination method used, which must extend [PaginationMethod].
/// [ErrorType] represents possible errors.
mixin PaginationHandler<ItemType, PM extends PaginationMethod, ErrorType>
    implements PaginationController<ItemType, PM, ErrorType> {
  /// Core logic for handling pagination requests.
  ///
  /// [pagination] is the current pagination pointer.
  /// [replaceOldList] determines whether the new items should replace the
  /// current list or be appended to it. By default, it's set to false.
  @protected
  Future<PaginationControllerState<ItemType, PM, ErrorType>> handlePagination(
      PaginationMethod pagination,
      [bool replaceOldList = false]) async {
    switch (state) {
      case DataListPCState<ItemType, PM, ErrorType>(:final itemList):
        final getPageResult = await getPageFunc(pagination as PM);

        switch (getPageResult) {
          case SuccessPaginationResult<ItemType, PM, ErrorType>(
              :final isLastItemList,
              itemList: final newItemList,
              :final pagination
            ):
            if (newItemList.isEmpty) {
              if (pagination == firstPagePointer) {
                return EmptyListPCState(
                  lastPagination: pagination,
                );
              } else {
                return DataListPCState(
                  itemList: itemList,
                  lastPagination: pagination,
                  isLastItems: true,
                );
              }
            }

            return DataListPCState(
              itemList:
                  replaceOldList ? newItemList : [...itemList, ...newItemList],
              lastPagination: pagination,
              isLastItems: isLastItemList,
            );
          case ErrorPaginationResult<ItemType, PM, ErrorType>(
              :final pagination
            ):
            return ErrorListPCState(lastPagination: pagination);
        }
      case ErrorListPCState<ItemType, PM, ErrorType>():
      case EmptyListPCState<ItemType, PM, ErrorType>():
        final getPageResult = await getPageFunc(pagination as PM);

        switch (getPageResult) {
          case SuccessPaginationResult<ItemType, PM, ErrorType>(
              :final isLastItemList,
              :final itemList,
              :final pagination
            ):
            if (itemList.isEmpty) {
              if (pagination == firstPagePointer) {
                return EmptyListPCState(
                  lastPagination: pagination,
                );
              } else {
                return DataListPCState(
                  itemList: itemList,
                  lastPagination: pagination,
                  isLastItems: true,
                );
              }
            }

            return DataListPCState(
              itemList: itemList,
              lastPagination: pagination,
              isLastItems: isLastItemList,
            );
          case ErrorPaginationResult<ItemType, PM, ErrorType>(
              :final pagination
            ):
            return ErrorListPCState(lastPagination: pagination);
        }
    }
  }

  /// Fetches the first page of data.
  @override
  Future<void> getFirst() async {
    isProcessing.value = true;
    state = await handlePagination(firstPagePointer, true);
    isProcessing.value = false;
  }

  /// Fetches the next page of data.
  @override
  Future<void> getNext() async {
    isProcessing.value = true;
    switch (state) {
      case DataListPCState<ItemType, PM, ErrorType>(:final lastPagination):
        state = await handlePagination(lastPagination.next());
        break;
      case EmptyListPCState<ItemType, PM, ErrorType>():
      case ErrorListPCState<ItemType, PM, ErrorType>():
        state = await handlePagination(firstPagePointer);
        break;
    }
    isProcessing.value = false;
  }

  /// Refreshes the current pagination.
  @override
  Future<void> refreshCurrent() async {
    isProcessing.value = true;
    switch (state) {
      case DataListPCState<ItemType, PM, ErrorType>(:final lastPagination):
        state = (await handlePagination(lastPagination.allCurrent(), true))
            .copyWithPagination(lastPagination);
        break;
      case EmptyListPCState<ItemType, PM, ErrorType>(:final lastPagination):
      case ErrorListPCState<ItemType, PM, ErrorType>(:final lastPagination):
        state = (await handlePagination(firstPagePointer, true))
            .copyWithPagination(lastPagination);
        break;
    }
    isProcessing.value = false;
  }
}
