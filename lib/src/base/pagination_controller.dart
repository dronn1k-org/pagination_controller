import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pagination_controller/src/base/pagination_controller_result.dart';
import 'package:pagination_controller/src/base/pagination_controller_state.dart';
import 'package:pagination_controller/src/base/pagination_method.dart';

/// An abstract class that defines a pagination controller.
///
/// [ItemType] is the type of items to be paginated.
/// [PM] is the pagination method that extends [PaginationMethod].
/// [ErrorType] defines the error type that the controller may return.
abstract interface class PaginationController<ItemType,
    PM extends PaginationMethod, ErrorType> {
  /// ScrollController used to track the scrolling events.
  abstract final ScrollController scrollController;

  /// A function that fetches the next page of data.
  /// [pagination] is the current pagination pointer.
  abstract final Future<PaginationResult<ItemType, PM, ErrorType>> Function(
      PM pagination) getPageFunc;

  /// The initial page pointer.
  abstract final PM firstPagePointer;

  /// A notifier to indicate if a page is being processed.
  abstract final ValueNotifier<bool> isProcessing;

  /// Current state of the pagination controller.
  PaginationControllerState<ItemType, PM, ErrorType> get state;

  /// Fetch the first page.
  Future<void> getFirst();

  /// Fetch the next page.
  Future<void> getNext();

  /// Refresh the current pagination.
  Future<void> refreshCurrent();

  void updateItem(int index, ItemType newItem);

  void removeItemAt(int index);
}
