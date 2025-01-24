import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pagination_controller/src/base/callback_depth_processor.dart';
import 'package:pagination_controller/src/base/pagination_controller_base.dart';

/// A pagination controller that uses the Bloc Cubit pattern for state management.
///
/// [ItemType] is the type of items being paginated.
/// [PM] is the pagination method that extends [PaginationMethod].
/// [ErrorType] defines the error type that the controller may return.
class CubitPaginationController<ItemType, PM extends PaginationMethod,
        ErrorType>
    extends Cubit<PaginationControllerState<ItemType, PM, ErrorType>>
    with PaginationHandler<ItemType, PM, ErrorType>, CallbackDepthProcessor
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
  Future<void> getFirst() =>
      process(() async => emit(await handlePagination(firstPagePointer, true)));

  /// Fetches the next page of data.
  @override
  Future<void> getNext() => process(() async =>
      emit(await handlePagination(state.nextPagination ?? firstPagePointer)));

  /// Refreshes the current pagination.
  @override
  Future<void> refreshCurrent() async =>
      process(() async => emit((await handlePagination(
              state.refreshingPagination ?? firstPagePointer, true))
          .copyWithPagination(state.lastPagination)));

  @override
  void updateItemAt(int index, ItemType newItem) =>
      process(() async => emit(state.updateItemAt(index, newItem)));

  @override
  void removeItemAt(int index) =>
      process(() async => emit(state.removeItemAt(index)));

  @override
  Future<void> close() {
    disposeDepthProcessor();
    return super.close();
  }
}
