import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pagination_controller/src/base/pagination_controller_base.dart';

/// A pagination controller that uses the Bloc Cubit pattern for state management.
///
/// [ItemType] is the type of items being paginated.
/// [PM] is the pagination method that extends [PaginationMethod].
/// [ErrorType] defines the error type that the controller may return.
class CubitPaginationController<ItemType, PM extends PaginationMethod,
        ErrorType>
    extends Cubit<PaginationControllerState<ItemType, PM, ErrorType>>
    with PaginationHandler<ItemType, PM, ErrorType>
    implements PaginationController<ItemType, PM, ErrorType> {
  /// The ScrollController used for detecting scrolling and loading new pages.
  @override
  late final ScrollController scrollController;

  /// The function responsible for fetching the next page of data based on the pagination pointer.
  @override
  final Future<PaginationResult<ItemType, PM, ErrorType>> Function(
      PM pagination) getPageFunc;

  /// The first pagination pointer, representing the starting page.
  @override
  final PM firstPagePointer;

  /// Creates a CubitPaginationController.
  ///
  /// [firstPagePointer] is the initial pagination method instance.
  /// [getPageFunc] is the function that fetches pages.
  /// [scrollController] can be optionally provided or it will be created internally.
  /// [loadFirstPageOnInit] defines whether the first page should be loaded on initialization.
  CubitPaginationController({
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

    if (loadFirstPageOnInit) getFirst();
  }

  /// A flag to prevent multiple invocations from the scroll listener.
  bool _hasAlreadyInvokedByScrollController = false;

  /// A notifier that tracks whether a page is currently being fetched.
  @override
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  /// Listens for scroll events and triggers loading of the next page when nearing the end of the list.
  void _scrollListener() async {
    if (_hasAlreadyInvokedByScrollController) return;
    if (this.scrollController.position.extentAfter < 200 &&
        this.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      switch (state) {
        case DataListPCState<ItemType, PM, ErrorType>(
            isLastItems: final isLastPage
          ):
          if (!isLastPage) {
            _hasAlreadyInvokedByScrollController = true;
            await getNext();
            _hasAlreadyInvokedByScrollController = false;
          }
          break;
        case EmptyListPCState<ItemType, PM, ErrorType>():
        case ErrorListPCState<ItemType, PM, ErrorType>():
          break;
      }
    }
  }

  /// Fetches the first page of data.
  @override
  Future<void> getFirst() async {
    isProcessing.value = true;
    try {
      emit(await handlePagination(firstPagePointer, true));
    } finally {
      isProcessing.value = false;
    }
  }

  /// Fetches the next page of data.
  @override
  Future<void> getNext() async {
    isProcessing.value = true;
    try {
      switch (state) {
        case DataListPCState<ItemType, PM, ErrorType>(:final lastPagination):
          emit(await handlePagination(lastPagination.next()));
          break;
        case EmptyListPCState<ItemType, PM, ErrorType>():
        case ErrorListPCState<ItemType, PM, ErrorType>():
          emit(await handlePagination(firstPagePointer));
          break;
      }
    } finally {
      isProcessing.value = false;
    }
  }

  /// Refreshes the current pagination.
  @override
  Future<void> refreshCurrent() async {
    isProcessing.value = true;
    try {
      switch (state) {
        case DataListPCState<ItemType, PM, ErrorType>(:final lastPagination):
          emit((await handlePagination(lastPagination.allCurrent(), true))
              .copyWithPagination(lastPagination));
          break;
        case EmptyListPCState<ItemType, PM, ErrorType>(:final lastPagination):
        case ErrorListPCState<ItemType, PM, ErrorType>(:final lastPagination):
          emit((await handlePagination(firstPagePointer, true))
              .copyWithPagination(lastPagination));
          break;
      }
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  Future<void> updateItem(int index, ItemType newItem) async {
    switch (state) {
      case DataListPCState<ItemType, PM, ErrorType>(
          :final itemList,
          :final isLastItems,
          :final lastPagination
        ):
        final newList = [...itemList];
        newList[index] = newItem;
        emit(DataListPCState(
          itemList: newList,
          isLastItems: isLastItems,
          lastPagination: lastPagination,
        ));
      case EmptyListPCState<ItemType, PM, ErrorType>():
      case ErrorListPCState<ItemType, PM, ErrorType>():
        throw Exception('State have no active list for the item updating.');
    }
  }
}
