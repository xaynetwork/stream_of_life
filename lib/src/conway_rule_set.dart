import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stream_of_life/src/cell.dart';
import 'package:stream_of_life/src/plane.dart';
import 'package:stream_of_life/src/slot.dart';

class _ConwayStreamSink<T> implements EventSink<LifetimeState> {
  final EventSink<Set<Cell>> _outputSink;
  final Plane _plane;
  StreamSubscription? _subscription;
  bool _didClose = false;

  _ConwayStreamSink(this._outputSink, this._plane);

  @override
  void add(LifetimeState data) async {
    if (data.isGenerationMilestone) {
      _outputSink.add(data.state);

      final toLocalArea = createLocalAreaBuilder(data.state);
      final maybeStayAliveAndListDeadSiblings =
          createMaybeStayAliveBuilder(data.state);
      final maybeCreateOffspring =
          createMaybeCreateOffspringBuilder(data.state);

      onDone() {
        _subscription = null;

        if (_didClose) {
          _outputSink.close();
        } else {
          _plane.markGeneration();
        }
      }

      _subscription = Stream.fromIterable(data.state)
          // test if currently living cells can stay alive
          .map(toLocalArea)
          .asyncExpand(maybeStayAliveAndListDeadSiblings)
          // test if the cell can produce offspring
          .map(toLocalArea)
          .map(maybeCreateOffspring)
          .listen(
            null,
            onDone: onDone,
            onError: _outputSink.addError,
          );
    }
  }

  @override
  void addError(e, [st]) => _outputSink.addError(e, st);

  @override
  void close() {
    _didClose = true;

    if (_subscription == null) _outputSink.close();
  }

  @visibleForTesting
  List<Slot> Function(Cell) createLocalAreaBuilder(Set<Cell> state) =>
      (centerCell) {
        final list = <Slot>[];

        for (var col = -1; col <= 1; col++) {
          for (var row = -1; row <= 1; row++) {
            final x = centerCell.x + col, y = centerCell.y + row;
            final cell = Cell(x: x, y: y);
            final hasCell = state.contains(cell);

            list.add(
              Slot(
                hasCell ? cell : null,
                x: x,
                y: y,
              ),
            );
          }
        }

        return List<Slot>.unmodifiable(list);
      };

  @visibleForTesting
  Stream<Cell> Function(List<Slot>) createMaybeStayAliveBuilder(
    Set<Cell> state,
  ) =>
      (grid) {
        final aliveSiblings = grid.aliveSiblingsCount;

        if (aliveSiblings < 2 || aliveSiblings > 3) {
          _plane.remove(grid.center.requireCell);
        }

        return Stream.fromIterable(grid.deadSiblings);
      };

  @visibleForTesting
  void Function(List<Slot>) createMaybeCreateOffspringBuilder(
    Set<Cell> state,
  ) =>
      (grid) {
        if (grid.aliveSiblingsCount == 3) _plane.add(grid.center.requireCell);
      };
}

class ConwayStreamTransformer
    extends StreamTransformerBase<LifetimeState, Set<Cell>> {
  final Plane _plane;

  ConwayStreamTransformer(this._plane);

  @override
  Stream<Set<Cell>> bind(Stream<LifetimeState> stream) =>
      Stream.eventTransformed(
          stream, (sink) => _ConwayStreamSink(sink, _plane));
}

extension ConwayExtension on Stream<LifetimeState> {
  Stream<Set<Cell>> conway(Plane plane) =>
      transform(ConwayStreamTransformer(plane));
}

extension _LocalAreaExtension on List<Slot> {
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
