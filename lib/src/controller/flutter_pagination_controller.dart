import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../base/pagination_controller_base.dart';

class FlutterPaginationController<ItemType, PM extends PaginationMethod,
        ErrorType>
    with ChangeNotifier, PaginationHandler<ItemType, PM, ErrorType>
    implements PaginationController<ItemType, PM, ErrorType> {
  PaginationControllerState<ItemType, PM, ErrorType> _state;

  @override
  final PM firstPagePointer;

  @override
  Future<PaginationResult<ItemType, PM, ErrorType>> Function(PM pagination)
      getPageFunc;

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

    if (loadFirstPageOnInit) getFirstPage();
  }

  @override
  late final ScrollController scrollController;
  @override
  PaginationControllerState<ItemType, PM, ErrorType> get state => _state;

  @override
  set state(PaginationControllerState<ItemType, PM, ErrorType> newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  bool _hasAlreadyInvokedByScrollController = false;

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
            await getNextPage();
            _hasAlreadyInvokedByScrollController = false;
          }
          break;
        case EmptyListPCState<ItemType, PM, ErrorType>():
        case ErrorListPCState<ItemType, PM, ErrorType>():
          break;
      }
    }
  }
}
