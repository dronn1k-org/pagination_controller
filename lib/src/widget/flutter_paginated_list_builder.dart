import 'package:flutter/widgets.dart';
import 'package:pagination_controller/src/base/pagination_controller_base.dart';
import 'package:pagination_controller/src/controller/flutter_pagination_controller.dart';

class FlutterPaginatedListBuilder<ItemType, PM extends PaginationMethod,
    ErrorType> extends StatelessWidget {
  final FlutterPaginationController<ItemType, PM, ErrorType> controller;
  final Widget Function(
      BuildContext context,
      DataListPCState<ItemType, PM, ErrorType> dataState,
      bool isProcessing) dataBuilder;
  final Widget Function(
      BuildContext context,
      EmptyListPCState<ItemType, PM, ErrorType> emptyState,
      bool isProcessing) emptyBuilder;
  final Widget Function(
      BuildContext context,
      ErrorListPCState<ItemType, PM, ErrorType> errorState,
      bool isProcessing) errorBuilder;

  const FlutterPaginatedListBuilder({
    super.key,
    required this.controller,
    required this.dataBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return _FlutterPaginatedListBuilder(
      controller: controller,
      builder: (context, state, isProcessing) => switch (state) {
        DataListPCState<ItemType, PM, ErrorType>() =>
          dataBuilder(context, state, isProcessing),
        EmptyListPCState<ItemType, PM, ErrorType>() =>
          emptyBuilder(context, state, isProcessing),
        ErrorListPCState<ItemType, PM, ErrorType>() =>
          errorBuilder(context, state, isProcessing),
      },
    );
  }
}

class _FlutterPaginatedListBuilder<ItemType, PM extends PaginationMethod,
    ErrorType> extends StatelessWidget {
  final FlutterPaginationController<ItemType, PM, ErrorType> controller;
  final Widget Function(
      BuildContext context,
      PaginationControllerState<ItemType, PM, ErrorType> state,
      bool isProcessing) builder;

  const _FlutterPaginatedListBuilder({
    super.key,
    required this.controller,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.isProcessing,
      builder: (context, isProcessing, _) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) =>
            builder(context, controller.state, isProcessing),
      ),
    );
  }
}
