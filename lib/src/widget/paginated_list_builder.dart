import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pagination_controller/pagination_controller.dart';

class PaginatedDataBuilderDevided<ItemType, PM extends PaginationMethod,
    ErrorType> extends StatelessWidget {
  final PaginationController<ItemType, PM, ErrorType>? controller;
  final Widget Function(BuildContext context,
      DataListPCState<ItemType, PM> dataState, bool isProcessing) dataBuilder;
  final Widget Function(
      BuildContext context,
      EmptyListPCState<ItemType, PM> emptyState,
      bool isProcessing) emptyBuilder;
  final Widget Function(
      BuildContext context,
      ErrorListPCState<ItemType, PM> errorState,
      bool isProcessing) errorBuilder;

  const PaginatedDataBuilderDevided({
    super.key,
    this.controller,
    required this.dataBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataBuilder(
      controller: controller,
      builder: (context, state, isProcessing) => switch (state) {
        DataListPCState<ItemType, PM>() =>
          dataBuilder(context, state, isProcessing),
        EmptyListPCState<ItemType, PM>() =>
          emptyBuilder(context, state, isProcessing),
        ErrorListPCState<ItemType, PM>() =>
          errorBuilder(context, state, isProcessing),
      },
    );
  }
}

class PaginatedDataBuilder<ItemType, PM extends PaginationMethod, ErrorType>
    extends StatelessWidget {
  final PaginationController<ItemType, PM, ErrorType>? controller;
  final Widget Function(BuildContext context,
      PaginationControllerState<ItemType, PM> state, bool isProcessing) builder;

  const PaginatedDataBuilder({
    super.key,
    this.controller,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ??
        context.read<PaginationController<ItemType, PM, ErrorType>>();
    return ValueListenableBuilder(
      valueListenable: controller.isProcessing,
      builder: (context, isProcessing, _) => BlocBuilder<
          PaginationController<ItemType, PM, ErrorType>,
          PaginationControllerState<ItemType, PM>>(
        bloc: controller,
        builder: (context, state) => builder(context, state, isProcessing),
      ),
    );
  }
}
