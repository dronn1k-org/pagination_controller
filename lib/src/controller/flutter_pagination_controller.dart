import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pagination_controller/pagination_controller.dart';
import 'package:pagination_controller/src/base/callback_depth_processor.dart';

/// A pagination controller that uses Flutter's ChangeNotifier for state management.
///
/// [ItemType] is the type of items being paginated.
/// [PM] is the pagination method that extends [PaginationMethod].
/// [ErrorType] defines the error type that the controller may return.
class FlutterPaginationController<ItemType, PM extends PaginationMethod,
        ErrorType>
    with
        ChangeNotifier,
        PaginationHandler<ItemType, PM, ErrorType>,
        CallbackDepthProcessor
    implements PaginationController<ItemType, PM, ErrorType> {
  /// The current state of the pagination.
  PaginationControllerState<ItemType, PM, ErrorType> _state;

  /// The first pagination pointer, representing the starting page.
  @override
  final PM firstPagePointer;

  /// The function responsible for fetching the next page of data based on the pagination pointer.
  @override
  Future<PaginationResult<ItemType, PM, ErrorType>> Function(PM pagination)
      getPageFunc;

  /// Creates a FlutterPaginationController.
  ///
  /// [firstPagePointer] is the initial pagination method instance.
  /// [getPageFunc] is the function that fetches pages.
  /// [scrollController] can be optionally provided or it will be created internally.
  /// [loadFirstPageOnInit] defines whether the first page should be loaded on initialization.
  /// [initialState] is an optional initial state for the controller.
  FlutterPaginationController({
    required this.firstPagePointer,
    final ScrollController? scrollController,
    final bool loadFirstPageOnInit = true,
    final PaginationControllerState<ItemType, PM, ErrorType>? initialState,
    required this.getPageFunc,
  }) : _state = initialState ??
            DataListPCState(
              itemList: [],
              lastPagination: firstPagePointer,
              isLastItems: false,
            ) {
    this.scrollController = scrollController ?? ScrollController();
    this.scrollController.addListener(_scrollListener);

    if (loadFirstPageOnInit) getFirst();
  }

  /// The ScrollController used for detecting scrolling and loading new pages.
  @override
  late final ScrollController scrollController;

  /// Gets the current state of the pagination.
  @override
  PaginationControllerState<ItemType, PM, ErrorType> get state => _state;

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
  Future<void> getFirst() => process(() async {
        _state = await handlePagination(firstPagePointer, true);
        notifyListeners();
      });

  /// Fetches the next page of data.
  @override
  Future<void> getNext() {
    return process(() async {
      _state =
          await handlePagination(_state.nextPagination ?? firstPagePointer);
      notifyListeners();
    });
  }

  /// Refreshes the current pagination.
  @override
  Future<void> refreshCurrent() => process(() async {
        _state = (await handlePagination(
                _state.refreshingPagination ?? firstPagePointer, true))
            .copyWithPagination(_state.lastPagination);
        notifyListeners();
      });

  /// Updates an Item at the given index if DataState is provided.
  @override
  void updateItemAt(int index, ItemType newItem) async {
    return process(() async {
      _state = _state.updateItemAt(index, newItem);
      notifyListeners();
    });
  }

  /// Remove an Item at the given index if DataState is provided
  @override
  void removeItemAt(int index) => process(() async {
        _state = _state.removeItemAt(index);
        notifyListeners();
      });

  @override
  void dispose() {
    disposeDepthProcessor();
    super.dispose();
  }
}
