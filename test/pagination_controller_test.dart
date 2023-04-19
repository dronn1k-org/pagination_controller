import 'package:flutter_test/flutter_test.dart';

import 'package:pagination_controller/src/pagination_controller.dart';
import 'package:pagination_controller/src/pagination_controller_result.dart';

class TemplateData {
  final int index;

  const TemplateData(this.index);
}

List<TemplateData> _testDataList =
    List<TemplateData>.generate(30, (index) => TemplateData(index));

void main() {
  late PaginationController<TemplateData> paginationCtrl;
  setUp(() {
    paginationCtrl = PaginationController<TemplateData>(
      firstPageKey: 0,
      itemsLimitPerPage: 10,
      getPageFunc: (pageKey, itemsLimitPerPage) {
        if (pageKey < 3) {
          return GetResult(
            status: GetStatus.success,
            itemList: _testDataList.sublist(
                pageKey * itemsLimitPerPage, (pageKey + 1) * itemsLimitPerPage),
          );
        } else {
          return const GetResult(status: GetStatus.fail);
        }
      },
    );
  });
  test('get pages', () async {
    expect(paginationCtrl.itemList.length, 0);
    await paginationCtrl.getFirstPage();
    expect(paginationCtrl.itemList.length, 10);
    await paginationCtrl.getNextPage();
    expect(paginationCtrl.itemList.length, 20);
  });
}
