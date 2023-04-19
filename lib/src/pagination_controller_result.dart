import 'dart:async';

enum GetStatus {
  success,
  fail,
}

class GetResult<ItemType> {
  final List<ItemType> itemList;
  final GetStatus status;
  final FutureOr<bool> Function()? onError;

  bool get isSuccess => status == GetStatus.success;

  const GetResult({
    required this.status,
    this.itemList = const [],
    this.onError,
  });
}
