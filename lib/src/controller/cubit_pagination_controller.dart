import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pagination_controller/src/base/pagination_controller_base.dart';

class CubitPaginationController<ItemType, PM extends PaginationMethod,
        ErrorType>
    extends Cubit<PaginationControllerState<ItemType, PM, ErrorType>>
    with PaginationHandler<ItemType, PM, ErrorType>
    implements PaginationController<ItemType, PM, ErrorType> {
  @override
  late final ScrollController scrollController;
  @override
  final Future<PaginationResult<ItemType, PM, ErrorType>> Function(
      PM pagination) getPageFunc;

  @override
  final PM firstPagePointer;

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

  bool _hasAlreadyInvokedByScrollController = false;

  @override
  set state(PaginationControllerState<ItemType, PM, ErrorType> newState) =>
      emit(newState);

  @override
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

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
}
