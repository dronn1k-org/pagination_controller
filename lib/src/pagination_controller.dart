import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pagination_controller/src/pagination_controller_result.dart';

class PaginationController<ItemType> extends ChangeNotifier {
  final int itemsLimitPerPage;
  late int _nextPageKey;
  late int _firstPageKey;

  int get nextPageKey => _nextPageKey;

  final List<ItemType> itemList = [];

  final StreamController<List<ItemType>> _itemListStreamCtrl =
      StreamController.broadcast();

  StreamSubscription<List<ItemType>>? _itemListStreamSub;

  late ScrollController scrollController;

  final FutureOr<GetResult<ItemType>> Function(
      int pageKey, int itemsLimitPerPage) getPageFunc;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLastPage = false;
  bool get allItemsLoaded => _isLastPage;
  void Function(List<ItemType>)? onItemsListChanged;

  PaginationController({
    required int firstPageKey,
    required this.getPageFunc,
    ScrollController? scrollController,
    this.itemsLimitPerPage = 15,
    this.onItemsListChanged,
  }) {
    this.scrollController = scrollController ?? ScrollController();
    _itemListStreamSub =
        _itemListStreamCtrl.stream.listen((_) => notifyListeners());
    _nextPageKey = _firstPageKey = firstPageKey;
    this.scrollController.addListener(() async {
      if (this.scrollController.position.extentAfter < 200 &&
          !_isLoading &&
          this.scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          !_isLastPage) {
        await getNextPage();
      }
    });
  }

  @override
  @mustCallSuper
  void dispose() {
    _itemListStreamSub?.cancel();
    super.dispose();
  }

  Future<void> getNextPage() async {
    final status = await _generalCallback(nextPageKey, itemsLimitPerPage);
    if (status) {
      _nextPageKey++;
    }
  }

  Future<void> getFirstPage() async {
    final status =
        await _generalCallback(_firstPageKey, itemsLimitPerPage, replace: true);
    if (status) {
      _nextPageKey = _firstPageKey + 1;
    } else {
      _nextPageKey = _firstPageKey;
    }
  }

  Future<void> refreshCurrentItems() async {
    final deviationFromFirst = 1 - _firstPageKey;
    final status = await _generalCallback(
      _firstPageKey,
      (_nextPageKey - 1 - deviationFromFirst) * itemsLimitPerPage,
      replace: true,
    );
  }

  Future<bool> _generalCallback(
    int currentPage,
    int itemsLimitPerPage, {
    bool replace = false,
  }) async {
    _isLoading = true;
    final result = await getPageFunc(currentPage, itemsLimitPerPage);
    if (!result.isSuccess) {
      return await result.onError?.call() ?? false;
    } else {
      final resultList = result.itemList;
      if (resultList.length < itemsLimitPerPage) {
        _isLastPage = true;
      } else if (_isLastPage) {
        _isLastPage = false;
      }
      if (resultList.isNotEmpty) {
        if (replace && itemList.isNotEmpty) {
          itemList.replaceRange(0, itemList.length, resultList);
        } else {
          itemList.addAll(resultList);
        }
        _itemListStreamCtrl.add(itemList);
      } else if (_firstPageKey == currentPage) {
        itemList.clear();
        _itemListStreamCtrl.add([]);
      }
    }
    onItemsListChanged?.call(itemList);
    _isLoading = false;
    return result.isSuccess;
  }

  StreamSubscription<List<ItemType>> listen(
    void Function(List<ItemType> list) listener, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _itemListStreamCtrl.stream.listen(
        listener,
        onDone: onDone,
        cancelOnError: cancelOnError,
        onError: onError,
      );
}
