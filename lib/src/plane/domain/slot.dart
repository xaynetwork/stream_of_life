import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/tool/hash_tools.dart' as hash;

class Slot {
  final Cell? cell;
  final int x, y;
  @override
  final int hashCode;

  Slot(
    this.cell, {
    required this.x,
    required this.y,
  }) : hashCode = hash.szdudzik(hash.szdudzik(x, y), cell != null ? 2 : 1);

  bool get hasCell => cell != null;

  Cell get requireCell => cell ?? Cell(x: x, y: y);

  @override
  bool operator ==(Object other) {
    if (other is Slot) {
      return other.x == x && other.y == y && other.cell == cell;
    }

    return false;
  }

  @override
  String toString() => 'x: $x, y: $y, cell: $cell';
}
