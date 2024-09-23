import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pagination_controller/pagination_controller.dart';

class PaginationController<ItemType, PM extends PaginationMethod, ErrorType>
    extends Cubit<PaginationControllerState<ItemType, PM>> {
  late final ScrollController scrollController;
  final FutureOr<PaginationResult<ItemType, PM, ErrorType>> Function(
      PM pagination) getPageFunc;

  final PM firstPagePointer;

  PaginationController({
    required this.firstPagePointer,
    final ScrollController? scrollController,
    final bool loadFirstPageOnInit = true,
    required this.getPageFunc,
  }) : super(DataListPCState(
          lastPagination: firstPagePointer,
          itemList: [],
          isLastItems: false,
        )) {
    this.scrollController = scrollController ?? ScrollController();
    this.scrollController.addListener(_scrollListener);

    if (loadFirstPageOnInit) getFirstPage();
  }

  bool _hasAlreadyInvokedByScrollController = false;

  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  void _scrollListener() async {
    if (_hasAlreadyInvokedByScrollController) return;
    if (this.scrollController.position.extentAfter < 200 &&
        this.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      switch (state) {
        case DataListPCState<ItemType, PM>(isLastItems: final isLastPage):
          if (!isLastPage) {
            _hasAlreadyInvokedByScrollController = true;
            await getNextPage();
            _hasAlreadyInvokedByScrollController = false;
          }
          break;
        case EmptyListPCState<ItemType, PM>():
        case ErrorListPCState<ItemType, PM>():
          break;
      }
    }
  }

  Future<void> getFirstPage() async {
    isProcessing.value = true;
    emit(await _generalCallback(firstPagePointer, replace: true));
    isProcessing.value = false;
  }

  Future<void> getNextPage() async {
    isProcessing.value = true;
    switch (state) {
      case DataListPCState<ItemType, PM>(:final lastPagination):
        emit(await _generalCallback(lastPagination.next()));
        break;
      case EmptyListPCState<ItemType, PM>():
      case ErrorListPCState<ItemType, PM>():
        emit(await _generalCallback(firstPagePointer));
        break;
    }
    isProcessing.value = false;
  }

  Future<void> refreshCurrentList() async {
    isProcessing.value = true;
    switch (state) {
      case DataListPCState<ItemType, PM>(:final lastPagination):
        emit(
            await _generalCallback(lastPagination.allCurrent(), replace: true));
        break;
      case EmptyListPCState<ItemType, PM>():
      case ErrorListPCState<ItemType, PM>():
        emit(await _generalCallback(firstPagePointer, replace: true));
        break;
    }
    isProcessing.value = false;
  }

  Future<PaginationControllerState<ItemType, PM>> _generalCallback(
    PaginationMethod pagination, {
    bool replace = false,
  }) async {
    switch (state) {
      case DataListPCState<ItemType, PM>(:final itemList):
        final getPageResult = await getPageFunc(pagination as PM);

        switch (getPageResult) {
          case SuccessPaginationResult<ItemType, PM, ErrorType>(
              :final isLastItemList,
              itemList: final newItemList,
              :final pagination
            ):
            if (newItemList.isEmpty) {
              if (pagination == firstPagePointer) {
                return EmptyListPCState();
              } else {
                return DataListPCState(
                  itemList: itemList,
                  lastPagination: pagination,
                  isLastItems: true,
                );
              }
            }

            return DataListPCState(
              itemList: replace ? newItemList : [...itemList, ...newItemList],
              lastPagination: pagination,
              isLastItems: isLastItemList,
            );
          case ErrorPaginationResult<ItemType, PM, ErrorType>():
            // TODO: Handle this case.
            return ErrorListPCState();
        }
      case ErrorListPCState<ItemType, PM>():
      case EmptyListPCState<ItemType, PM>():
        final getPageResult = await getPageFunc(pagination as PM);

        switch (getPageResult) {
          case SuccessPaginationResult<ItemType, PM, ErrorType>(
              :final isLastItemList,
              :final itemList,
              :final pagination
            ):
            if (itemList.isEmpty) {
              if (pagination == firstPagePointer) {
                return EmptyListPCState();
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
          case ErrorPaginationResult<ItemType, PM, ErrorType>():
            // TODO: Handle this case.
            return ErrorListPCState();
        }
    }
  }
}
