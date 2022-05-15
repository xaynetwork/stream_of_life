class Cell {
  final int x, y;

  const Cell({
    required this.x,
    required this.y,
  });

  @override
  bool operator ==(Object other) {
    if (other is Cell) {
      return other.x == x && other.y == y;
    }

    return false;
  }

  /// Suzuki's hash of 2 ints
  @override
  int get hashCode => x >= y ? x * x + x + y : x + y * y;

  @override
  String toString() => '$x,$y';
}
