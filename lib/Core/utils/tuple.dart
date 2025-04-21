/// Helper class for Selector with 2 values.
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          item1 == other.item1 &&
          item2 == other.item2;

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;
}

/// Helper class for Selector with 3 values.
class Tuple3<T1, T2, T3> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  Tuple3(this.item1, this.item2, this.item3);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple3 &&
          runtimeType == other.runtimeType &&
          item1 == other.item1 &&
          item2 == other.item2 &&
          item3 == other.item3;

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode ^ item3.hashCode;
}
