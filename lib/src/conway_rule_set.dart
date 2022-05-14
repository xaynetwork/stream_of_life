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
        .asyncExpand((cells) {
          final toLocalArea = createLocalAreaBuilder(cells);
          final maybeStayAliveAndListDeadSiblings =
              createMaybeStayAliveBuilder(cells);
          final maybeCreateOffspring = createMaybeCreateOffspringBuilder(cells);

          return Stream.fromIterable(cells)
              // test if currently living cells can stay alive
              .map(toLocalArea)
              .asyncExpand(maybeStayAliveAndListDeadSiblings)
              // test if the cell can produce offspring
              .map(toLocalArea)
              .map(maybeCreateOffspring)
              // mark the current generation as completed
              .doOnDone(_plane.markGeneration);
        })
        .listen(null)
        .addTo(_subscriptions);
  }

  Stream<Set<Cell>> get events => _plane.state
      .where((it) => it.isGenerationMilestone)
      .map((it) => it.state);

  @visibleForTesting
  Iterable<Slot> Function(Cell) createLocalAreaBuilder(HashSet<Cell> state) =>
      (centerCell) {
        final list = <Slot>[];

        for (var col = -1; col <= 1; col++) {
          for (var row = -1; row <= 1; row++) {
            final x = centerCell.x + col, y = centerCell.y + row;
            final cell = Cell(x: x, y: y);
            final hasCell = state.contains(cell);

            list.add(Slot(
              hasCell ? cell : null,
              x: x,
              y: y,
            ));
          }
        }

        return List<Slot>.unmodifiable(list);
      };

  @mustCallSuper
  void dispose() {
    _subscriptions.dispose();
    _plane.dispose();
  }

  @visibleForTesting
  Stream<Cell> Function(Iterable<Slot>) createMaybeStayAliveBuilder(
    HashSet<Cell> state,
  ) =>
      (grid) {
        // subtract 1, which is the center cell itself
        final aliveSiblings = grid.aliveSiblingsCount - 1;

        if (aliveSiblings < 2 || aliveSiblings > 3) {
          _plane.remove(grid.center.requireCell);
        }

        return Stream.fromIterable(grid.deadSiblings);
      };

  @visibleForTesting
  void Function(Iterable<Slot>) createMaybeCreateOffspringBuilder(
    Set<Cell> state,
  ) =>
      (grid) {
        if (grid.aliveSiblingsCount == 3) _plane.add(grid.center.requireCell);
      };
}

extension _LocalAreaExtension on Iterable<Slot> {
  Slot get center => elementAt(4);

  int get aliveSiblingsCount => where((it) => it.hasCell).length;

  Iterable<Cell> get deadSiblings =>
      where((it) => !it.hasCell).map((it) => it.requireCell);
}
