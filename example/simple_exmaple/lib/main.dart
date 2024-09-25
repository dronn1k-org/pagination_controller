import 'package:flutter/material.dart';
import 'package:pagination_controller/pagination_controller.dart';

class TemplateData {
  final int index;

  const TemplateData(this.index);
}

List<TemplateData> _testDataList =
    List<TemplateData>.generate(30, (index) => TemplateData(index));

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final controller =
      CubitPaginationController<TemplateData, OffsetPagination, String>(
    firstPagePointer: const OffsetPagination(offset: 0),
    getPageFunc: (pagination) {
      return Future.delayed(
          const Duration(seconds: 2),
          () => SuccessPaginationResult(
                itemList: _testDataList
                    .skip(pagination.offset)
                    .take(pagination.limit)
                    .toList(),
                pagination: pagination,
              ));
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => controller.getFirst(),
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: CubitPaginatedListBuilder(
                controller: controller,
                dataBuilder: (context, state, isProcessing) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...state.itemList.map(
                      (e) => Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(e.index.toString()),
                      ),
                    ),
                    if (isProcessing) const CircularProgressIndicator(),
                  ],
                ),
                emptyBuilder: (context, emptyState, isProcessing) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Text('empty'),
                ),
                errorBuilder: (context, emptyState, isProcessing) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Text('error'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
