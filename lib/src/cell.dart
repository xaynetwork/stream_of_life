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

  @override
  int get hashCode => Object.hashAll([x, y]);

  @override
  String toString() => '$x,$y';
}
