import 'package:stream_of_life/src/plane/domain/cell.dart';
import 'package:stream_of_life/src/plane/plane.dart';
import 'package:stream_of_life/src/stream_transformers/conway_stream_transformer.dart';
import 'package:test/test.dart';

const Matcher kIsDateTime = TypeMatcher<DateTime>();

void main() {
  test('WHEN only 1 cell THEN cell dies', () {
    final game = Plane.seeded({const Cell(x: 0, y: 0)});

    expect(
        game.state.conway(game),
        emitsInOrder([
          {const Cell(x: 0, y: 0)},
          <Cell>{},
        ]));
  });

  test('WHEN only 2 cells THEN both cells die', () {
    final game = Plane.seeded({const Cell(x: 0, y: 0), const Cell(x: 1, y: 0)});

    expect(
        game.state.conway(game),
        emitsInOrder([
          {const Cell(x: 0, y: 0), const Cell(x: 1, y: 0)},
          <Cell>{},
        ]));
  });
}
