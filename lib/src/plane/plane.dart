import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';
import 'package:stream_of_life/src/plane/domain/operation.dart';
import 'package:stream_of_life/src/plane/plane_controller.dart';
import 'package:stream_of_life/src/plane/plane_stream.dart';

class Plane implements PlaneStream, PlaneController {
  late final Stream<LifetimeState> _state;
  final StreamController<Cell> _onAddCell = StreamController<Cell>();
  final StreamController<Cell> _onRemoveCell = StreamController<Cell>();
  final StreamController<void> _onGeneration = StreamController<void>();

  @override
  Stream<LifetimeState> get state => _state;

  Plane.seeded(Set<Cell> cells) {
    final initialState = LifetimeState.mature(HashSet.of(cells));
    final addOperations = _onAddCell.stream.map(CellOperation.add);
    final removeOperations = _onRemoveCell.stream.map(CellOperation.remove);
    final generationOperation =
        _onGeneration.stream.mapTo(const CellOperation.increaseAge());
    final allOperations = Rx.merge([
      addOperations,
      removeOperations,
      generationOperation,
    ]);

    _state = allOperations
        .distinct()
        .scan(execOperation, initialState)
        .startWith(initialState);
  }

  @override
  void add(Cell cell) => _onAddCell.add(cell);

  @override
  void remove(Cell cell) => _onRemoveCell.add(cell);

  @override
  void markGeneration() => _onGeneration.add(null);

  @override
  void dispose() {
    _onAddCell.close();
    _onRemoveCell.close();
    _onGeneration.close();
  }

  @visibleForTesting
  LifetimeState execOperation(
      LifetimeState lifetime, CellOperation cellOperation, int index) {
    switch (cellOperation.operation) {
      case Operation.add:
        final nextCells = HashSet.of(lifetime.state);
        return LifetimeState.growing(nextCells..add(cellOperation.requireCell));
      case Operation.remove:
        final nextCells = HashSet.of(lifetime.state);
        return LifetimeState.growing(
            nextCells..remove(cellOperation.requireCell));
      case Operation.increaseAge:
        return LifetimeState.mature(lifetime.state);
    }
  }
}
