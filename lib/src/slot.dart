import 'package:stream_of_life/src/cell.dart';

class Slot {
  final Cell? cell;
  final int x, y;

  const Slot(
    this.cell, {
    required this.x,
    required this.y,
  });

  bool get hasCell => cell != null;

  Cell get requireCell => cell ?? Cell(x: x, y: y);

  @override
  String toString() => 'x: $x, y: $y, cell: $cell';
}
