import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_of_life/src/cell.dart';

class Plane {
  late final Stream<LifetimeState> _state;
  final StreamController<Cell> _onAddCell = StreamController<Cell>();
  final StreamController<Cell> _onRemoveCell = StreamController<Cell>();
  final StreamController<void> _onGeneration = StreamController<void>();

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

  void add(Cell cell) => _onAddCell.add(cell);

  void remove(Cell cell) => _onRemoveCell.add(cell);

  void markGeneration() => _onGeneration.add(null);

  void dispose() {
    _onAddCell.close();
    _onRemoveCell.close();
    _onGeneration.close();
  }

  @visibleForTesting
  LifetimeState execOperation(
      LifetimeState lifetime, CellOperation cellOperation, int index) {
    final nextCells = HashSet.of(lifetime.state);

    switch (cellOperation.operation) {
      case Operation.add:
        return LifetimeState.growing(nextCells..add(cellOperation.requireCell));
      case Operation.remove:
        return LifetimeState.growing(
            nextCells..remove(cellOperation.requireCell));
      case Operation.increaseAge:
        return LifetimeState.mature(nextCells);
    }
  }
}

@visibleForTesting
enum Operation { add, remove, increaseAge }

@visibleForTesting
class CellOperation {
  final Operation operation;
  final Cell? cell;

  Cell get requireCell => cell!;

  const CellOperation.add(this.cell) : operation = Operation.add;
  const CellOperation.remove(this.cell) : operation = Operation.remove;
  const CellOperation.increaseAge()
      : cell = null,
        operation = Operation.increaseAge;

  @override
  bool operator ==(Object other) {
    if (other is CellOperation) {
      return other.operation == operation && other.cell == cell;
    }

    return false;
  }

  @override
  int get hashCode => '${operation.name}, $cell'.hashCode;

  @override
  String toString() => 'op: $operation, cell: $cell';
}

class LifetimeState {
  final HashSet<Cell> state;
  final bool isGenerationMilestone;

  const LifetimeState.growing(this.state) : isGenerationMilestone = false;
  const LifetimeState.mature(this.state) : isGenerationMilestone = true;

  @override
  bool operator ==(Object other) {
    if (other is LifetimeState) {
      return other.isGenerationMilestone == isGenerationMilestone &&
          const SetEquality().equals(other.state, state);
    }

    return false;
  }

  @override
  int get hashCode => '$isGenerationMilestone, $state'.hashCode;

  @override
  String toString() =>
      'isGenerationMilestone: $isGenerationMilestone, state: $state';
}
