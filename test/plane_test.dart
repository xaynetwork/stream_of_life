import 'dart:collection';

import 'package:stream_of_life/src/plane/domain/lifetime_state.dart';
import 'package:stream_of_life/src/plane/domain/operation.dart';
import 'package:stream_of_life/src/plane/plane.dart';
import 'package:test/test.dart';
import 'package:stream_of_life/src/plane/domain/cell.dart';

void main() {
  test('ENSURE THAT plane.execOperation is a pure Function', () {
    final plane = Plane.seeded(const {});

    final a = plane.execOperation(
        LifetimeState.mature(HashSet.of({const Cell(x: 0, y: 0)})),
        const CellOperation.add(Cell(x: 1, y: 0)),
        0);
    final b = plane.execOperation(
        LifetimeState.mature(HashSet.of({const Cell(x: 0, y: 0)})),
        const CellOperation.add(Cell(x: 1, y: 0)),
        0);

    expect(a, b);
  });

  test('WHEN adding cells, THEN state updates correctly', () {
    final plane = Plane.seeded(const {});

    plane.add(const Cell(x: 0, y: 0));
    plane.add(const Cell(x: 1, y: 0));
    plane.add(const Cell(x: 2, y: 0));

    expect(
        plane.state,
        emitsInOrder([
          LifetimeState.mature(HashSet.of([])),
          LifetimeState.growing(HashSet.of([
            const Cell(x: 0, y: 0),
          ])),
          LifetimeState.growing(HashSet.of([
            const Cell(x: 0, y: 0),
            const Cell(x: 1, y: 0),
          ])),
          LifetimeState.growing(HashSet.of([
            const Cell(x: 0, y: 0),
            const Cell(x: 1, y: 0),
            const Cell(x: 2, y: 0),
          ])),
        ]));
  });

  test('WHEN removing cells, THEN state updates correctly', () {
    final plane = Plane.seeded({
      const Cell(x: 0, y: 0),
      const Cell(x: 1, y: 0),
      const Cell(x: 2, y: 0),
    });

    plane.remove(const Cell(x: 1, y: 0));
    plane.remove(const Cell(x: 2, y: 0));

    expect(
        plane.state,
        emitsInOrder([
          LifetimeState.mature(HashSet.of([
            const Cell(x: 0, y: 0),
            const Cell(x: 1, y: 0),
            const Cell(x: 2, y: 0),
          ])),
          LifetimeState.growing(HashSet.of([
            const Cell(x: 0, y: 0),
            const Cell(x: 2, y: 0),
          ])),
          LifetimeState.growing(HashSet.of([
            const Cell(x: 0, y: 0),
          ])),
        ]));
  });
}
