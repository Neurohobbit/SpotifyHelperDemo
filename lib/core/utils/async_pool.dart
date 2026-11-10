Future<List<R>> mapPool<T, R>({
  required List<T> items,
  required int concurrency,
  required Future<R> Function(T item) mapper,
}) async {
  if (items.isEmpty) {
    return <R>[];
  }
  final results = List<R?>.filled(items.length, null);
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      final index = nextIndex++;
      if (index >= items.length) {
        return;
      }
      results[index] = await mapper(items[index]);
    }
  }

  final workerCount =
      concurrency < items.length ? concurrency : items.length;
  await Future.wait(
    List<Future<void>>.generate(workerCount, (_) => worker()),
  );
  return [for (final result in results) result as R];
}
