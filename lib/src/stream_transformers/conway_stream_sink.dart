import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';
import 'package:stream_of_life/src/plane/domain/extension/slot_list_extension.dart';
import 'package:stream_of_life/src/plane/plane_sink.dart';
import 'package:stream_of_life/src/plane/domain/slot.dart';

class ConwayStreamSink<T> implements EventSink<LifetimeState> {
  final EventSink<Set<Cell>> _outputSink;
  final PlaneSink _plane;
  StreamSubscription? _subscription;
  bool _didClose = false;

  ConwayStreamSink(this._outputSink, this._plane);

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

        return List.unmodifiable(list);
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
