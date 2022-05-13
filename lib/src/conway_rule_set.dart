import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_of_life/src/cell.dart';
import 'package:stream_of_life/src/plane.dart';
import 'package:stream_of_life/src/slot.dart';

typedef ReadySignal = Future<LifetimeState> Function(LifetimeState);

class ConwayRuleSet {
  late final Plane _plane;
  late final CompositeSubscription _subscriptions = CompositeSubscription();

  ConwayRuleSet.seeded(
    Set<Cell> cells, {
    int years = 1000,
    ReadySignal? readySignal,
  }) {
    _plane = Plane.seeded(cells);

    _plane.state
        .where((it) => it.isGenerationMilestone)
        .asyncMap((it) => readySignal?.call(it) ?? Future.value(it))
        .take(years)
        .map((it) => it.state)
        .asyncExpand((cells) => Stream.fromIterable(cells)
            // test if currently living cells can stay alive
            .map(cropLocalArea(cells))
            .asyncExpand(maybeStayAlive(cells))
            // test if the cell can produce offspring
            .map(cropLocalArea(cells))
            .map(maybeCreateOffspring(cells))
            // mark the current generation as completed
            .doOnDone(_plane.markGeneration))
        .listen(null)
        .addTo(_subscriptions);
  }

  Stream<Set<Cell>> get events => _plane.state
      .where((it) => it.isGenerationMilestone)
      .map((it) => it.state);

  @visibleForTesting
  Iterable<Slot> Function(Cell) cropLocalArea(HashSet<Cell> state) =>
      (centerCell) sync* {
        for (var col = -1; col <= 1; col++) {
          for (var row = -1; row <= 1; row++) {
            final x = centerCell.x + col, y = centerCell.y + row;
            final cell = Cell(x: x, y: y);
            final hasCell = state.contains(cell);

            yield Slot(
              hasCell ? cell : null,
              x: x,
              y: y,
            );
          }
        }
      };

  @mustCallSuper
  void dispose() {
    _subscriptions.dispose();
    _plane.dispose();
  }

  @visibleForTesting
  Stream<Cell> Function(Iterable<Slot>) maybeStayAlive(HashSet<Cell> state) =>
      (Iterable<Slot> grid) async* {
        final mainSlot = grid.elementAt(4);
        var aliveSiblings = -1;

        for (final slot in grid) {
          if (slot.hasCell) {
            aliveSiblings++;
          } else {
            yield slot.requireCell;
          }
        }

        if (aliveSiblings < 2 || aliveSiblings > 3) {
          _plane.remove(mainSlot.requireCell);
        }
      };

  @visibleForTesting
  void Function(Iterable<Slot>) maybeCreateOffspring(Set<Cell> state) =>
      (Iterable<Slot> grid) {
        final mainSlot = grid.elementAt(4);
        final aliveSiblings = grid.where((it) => it.hasCell).length;

        if (aliveSiblings == 3) {
          _plane.add(mainSlot.requireCell);
        }
      };
}
