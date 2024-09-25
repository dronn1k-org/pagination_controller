import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagination_controller/pagination_controller.dart';

class TemplateData {
  final int index;

  const TemplateData(this.index);
}

List<TemplateData> _testDataList =
    List<TemplateData>.generate(30, (index) => TemplateData(index));

void main() {
  group('pagination tests', () {
    late CubitPaginationController<TemplateData, OffsetPagination, String>
        controller;
    const firstPagePointer = OffsetPagination(offset: 0);
    setUp(() {
      controller = CubitPaginationController(
        firstPagePointer: firstPagePointer,
        loadFirstPageOnInit: false,
        getPageFunc: (pagination) async {
          return SuccessPaginationResult(
            itemList: _testDataList
                .skip(pagination.offset)
                .take(pagination.limit)
                .toList(),
            pagination: pagination,
          );
        },
      );
    });
    blocTest(
      'getFirstPage',
      build: () => controller,
      act: (bloc) => bloc.getFirst(),
      expect: () => <dynamic>[
        isA<DataListPCState<TemplateData, OffsetPagination, String>>()
            .having((s) => s.isLastItems, 'isLastPage', false)
            .having((s) => s.itemList.length, 'itemList.length',
                firstPagePointer.limit),
      ],
    );
    blocTest(
      'getSecondPage',
      build: () => controller,
      act: (bloc) {
        bloc.getFirst();
        bloc.getNext();
      },
      skip: 1,
      expect: () => <dynamic>[
        isA<DataListPCState<TemplateData, OffsetPagination, String>>()
            .having((s) => s.isLastItems, 'isLastPage', false)
            .having((s) => s.itemList.length, 'itemList.length',
                firstPagePointer.limit * 2)
            .having((s) => s.lastPagination.offset, 'lastPagination.offset',
                firstPagePointer.limit),
      ],
    );
  });
}
