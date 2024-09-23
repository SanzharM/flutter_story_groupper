class Ticker {
  final Duration tickDuration;

  Ticker({
    this.tickDuration = const Duration(seconds: 1),
  });

  Stream<int> tick({int ticks = 0}) {
    return Stream.periodic(
      tickDuration,
      (x) => ticks - x - 1,
    ).take(ticks);
  }
}
