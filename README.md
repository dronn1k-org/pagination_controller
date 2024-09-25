# Pagination Controller

The `pagination_controller` package provides an abstract and reusable pagination logic for Flutter applications. It supports different pagination methods such as offset-based and page-based pagination. It also integrates with `ScrollController` for automatic loading of new data as users scroll.

## Features

- **Supports different pagination methods:** `OffsetPagination`, `PagePagination`.
- **Mixin-based Pagination Handling:** Allows easy integration with both Cubit and Flutter state management approaches.
- **Error and Empty States Handling:** Easily manage different states like errors, empty lists, and data retrieval success.
- **Customizable:** Allows usage of different item types, pagination strategies, and error types.

## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  pagination_controller: ^0.0.1
```

Then, run `flutter pub get` to install the package.

## Usage

### Example: Using Cubit for Pagination

```dart
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
        appBar: AppBar(title: const Text('Pagination Example')),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => controller.getFirst(),
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: CubitPaginatedListBuilder<TemplateData, OffsetPagination, String>(
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
                  child: const Text('No items available'),
                ),
                errorBuilder: (context, errorState, isProcessing) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Text('An error occurred'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

### Example: Using ScrollController for Pagination

```dart
final flutterController = FlutterPaginationController<ItemType, PagePagination, ErrorType>(
  firstPagePointer: PagePagination(page: 1),
  getPageFunc: (pagination) async {
    // Fetch data from an API or database
  },
);

// Use flutterController with any scrollable widget, like ListView
```

## Pagination Methods

### OffsetPagination

Offset-based pagination using a limit and offset strategy.

### PagePagination

Page-based pagination using page numbers and limit per page.

## State Management

The package supports three primary states:
1. `DataListPCState`: Holds the list of items and the current pagination state.
2. `EmptyListPCState`: Represents an empty list.
3. `ErrorListPCState`: Represents an error during pagination.

## License

This package is licensed under the MIT License.