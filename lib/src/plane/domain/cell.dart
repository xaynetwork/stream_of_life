class Cell {
  final int x, y;
  @override
  final int hashCode;

  const Cell({
    required this.x,
    required this.y,
  }) : hashCode = x >= y ? x * x + x + y : x + y * y;

  @override
  bool operator ==(Object other) {
    if (other is Cell) {
      return other.x == x && other.y == y;
    }

    return false;
  }

  @override
  String toString() => '$x,$y';
}
