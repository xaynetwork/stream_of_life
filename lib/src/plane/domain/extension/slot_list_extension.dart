import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/plane/domain/slot.dart';

extension LocalAreaExtension on List<Slot> {
  Slot get center => this[4];

  int get aliveSiblingsCount {
    final a = this[0],
        b = this[1],
        c = this[2],
        d = this[3],
        e = this[5],
        f = this[6],
        g = this[7],
        h = this[8];

    return (a.hasCell ? 1 : 0) +
        (b.hasCell ? 1 : 0) +
        (c.hasCell ? 1 : 0) +
        (d.hasCell ? 1 : 0) +
        (e.hasCell ? 1 : 0) +
        (f.hasCell ? 1 : 0) +
        (g.hasCell ? 1 : 0) +
        (h.hasCell ? 1 : 0);
  }

  Iterable<Cell> get deadSiblings {
    final a = this[0],
        b = this[1],
        c = this[2],
        d = this[3],
        e = this[5],
        f = this[6],
        g = this[7],
        h = this[8];

    return [
      if (!a.hasCell) a.requireCell,
      if (!b.hasCell) b.requireCell,
      if (!c.hasCell) c.requireCell,
      if (!d.hasCell) d.requireCell,
      if (!e.hasCell) e.requireCell,
      if (!f.hasCell) f.requireCell,
      if (!g.hasCell) g.requireCell,
      if (!h.hasCell) h.requireCell,
    ];
  }
}
