import 'package:stream_of_life/src/plane/domain/cell.dart';

enum Operation { add, remove, increaseAge }

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
  int get hashCode => Object.hashAll([operation, cell]);

  @override
  String toString() => 'op: $operation, cell: $cell';
}
